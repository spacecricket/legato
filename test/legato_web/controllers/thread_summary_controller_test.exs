defmodule LegatoWeb.ThreadSummaryControllerTest do
  use LegatoWeb.ConnCase, async: true

  alias Legato.Repo
  alias Legato.Chat.Schemas.{Thread, ThreadMember, User, Workspace}

  setup %{conn: conn} do
    workspace = insert_workspace()
    user = insert_user(workspace)
    other_user = insert_user(workspace, %{email: "other@example.com", handle: "other"})

    conn =
      Plug.Test.init_test_session(conn, %{
        signed_in: true,
        workspace_id: workspace.id,
        user_id: user.id
      })

    {:ok, conn: conn, workspace: workspace, user: user, other_user: other_user}
  end

  describe "GET /api/workspaces/:workspace_id/users/:user_id/active-thread-summaries" do
    test "wraps active thread summaries in an envelope",
         %{conn: conn, workspace: workspace, user: user} do
      unread =
        insert_thread(workspace, %{
          name: "unread",
          message_count: 1,
          last_message_at: ~U[2026-01-01 00:00:00Z]
        })

      read =
        insert_thread(workspace, %{
          name: "read",
          message_count: 1,
          last_message_at: ~U[2026-02-01 00:00:00Z]
        })

      insert_thread_member(unread, user)
      insert_thread_member(read, user, %{watermark: 1})

      body =
        conn
        |> get(active_thread_summaries_path(workspace, user))
        |> json_response(200)

      assert Map.keys(body) == ["threadSummaries"]
      assert [%{"thread" => %{"name" => "unread"}}] = body["threadSummaries"]
    end

    test "scopes active threads to the workspace",
         %{conn: conn, workspace: workspace, user: user} do
      other_workspace = insert_workspace(%{slug: "other", name: "Other"})

      foreign_thread =
        insert_thread(other_workspace, %{
          name: "foreign",
          message_count: 1,
          last_message_at: ~U[2026-01-01 00:00:00Z]
        })

      insert_thread_member(foreign_thread, user)

      body =
        conn
        |> get(active_thread_summaries_path(workspace, user))
        |> json_response(200)

      assert body["threadSummaries"] == []
    end
  end

  describe "GET /api/workspaces/:workspace_id/users/:user_id/thread-summaries" do
    test "returns threads the user is a member of, ordered by latest activity",
         %{conn: conn, workspace: workspace, user: user, other_user: other_user} do
      other_workspace = insert_workspace(%{slug: "other", name: "Other"})

      older =
        insert_thread(workspace, %{
          name: "older",
          last_message_at: ~U[2026-01-01 00:00:00Z]
        })

      newer =
        insert_thread(workspace, %{
          name: "newer",
          last_message_at: ~U[2026-02-01 00:00:00Z]
        })

      no_messages = insert_thread(workspace, %{name: "no messages"})

      insert_thread_member(older, user)
      insert_thread_member(newer, user)
      insert_thread_member(no_messages, user)

      not_a_member =
        insert_thread(workspace, %{
          name: "not a member",
          last_message_at: ~U[2026-03-01 00:00:00Z]
        })

      insert_thread_member(not_a_member, other_user)

      foreign_thread =
        insert_thread(other_workspace, %{
          name: "foreign",
          last_message_at: ~U[2026-04-01 00:00:00Z]
        })

      insert_thread_member(foreign_thread, user)

      body =
        conn
        |> get(thread_summaries_path(workspace, user))
        |> json_response(200)

      assert %{"threadSummaries" => summaries, "nextCursor" => nil} = body

      assert Enum.map(summaries, & &1["thread"]["name"]) == [
               "newer",
               "older",
               "no messages"
             ]

      assert Enum.all?(summaries, &(not Map.has_key?(&1, "inboundZaps")))
      assert Enum.all?(summaries, &(&1["watermark"]["sequenceNumber"] == 0))
    end

    test "excludes deleted threads and deleted memberships",
         %{conn: conn, workspace: workspace, user: user} do
      kept =
        insert_thread(workspace, %{
          name: "kept",
          last_message_at: ~U[2026-01-01 00:00:00Z]
        })

      deleted_thread =
        insert_thread(workspace, %{
          name: "deleted thread",
          is_deleted: true,
          last_message_at: ~U[2026-02-01 00:00:00Z]
        })

      deleted_membership =
        insert_thread(workspace, %{
          name: "deleted membership",
          last_message_at: ~U[2026-03-01 00:00:00Z]
        })

      insert_thread_member(kept, user)
      insert_thread_member(deleted_thread, user)
      insert_thread_member(deleted_membership, user, %{is_deleted: true})

      body =
        conn
        |> get(thread_summaries_path(workspace, user))
        |> json_response(200)

      assert Enum.map(body["threadSummaries"], & &1["thread"]["name"]) == ["kept"]
    end

    test "paginates through results with a cursor",
         %{conn: conn, workspace: workspace, user: user} do
      for i <- 1..3 do
        thread =
          insert_thread(workspace, %{
            name: "thread #{i}",
            last_message_at: DateTime.add(~U[2026-01-01 00:00:00Z], i, :day)
          })

        insert_thread_member(thread, user)
      end

      path = thread_summaries_path(workspace, user)

      first_page = conn |> get(path, %{"limit" => "2"}) |> json_response(200)

      assert Enum.map(first_page["threadSummaries"], & &1["thread"]["name"]) == [
               "thread 3",
               "thread 2"
             ]

      refute is_nil(first_page["nextCursor"])

      second_page =
        conn
        |> get(path, %{"limit" => "2", "cursor" => first_page["nextCursor"]})
        |> json_response(200)

      assert Enum.map(second_page["threadSummaries"], & &1["thread"]["name"]) == [
               "thread 1"
             ]

      assert is_nil(second_page["nextCursor"])
    end

    test "rejects invalid limits and cursors",
         %{conn: conn, workspace: workspace, user: user} do
      path = thread_summaries_path(workspace, user)

      assert %{"error" => "Invalid limit"} =
               conn |> get(path, %{"limit" => "0"}) |> json_response(400)

      assert %{"error" => "Invalid limit"} =
               conn |> get(path, %{"limit" => "abc"}) |> json_response(400)

      assert %{"error" => "Invalid cursor"} =
               conn |> get(path, %{"cursor" => "not-a-cursor"}) |> json_response(400)
    end

    test "returns 401 when not signed in",
         %{conn: conn, workspace: workspace, user: user} do
      conn = Plug.Test.init_test_session(conn, %{signed_in: false})

      assert %{"error" => "Not signed in"} =
               conn |> get(thread_summaries_path(workspace, user)) |> json_response(401)
    end

    test "returns 400 when the workspace does not match the session",
         %{conn: conn, user: user} do
      other_workspace = insert_workspace(%{slug: "other", name: "Other"})

      assert %{"error" => "No workspace in session or slug mismatch"} =
               conn
               |> get(thread_summaries_path(other_workspace, user))
               |> json_response(400)
    end

    test "returns 400 when the user does not match the session",
         %{conn: conn, workspace: workspace, other_user: other_user} do
      assert %{"error" => "User mismatch"} =
               conn
               |> get(thread_summaries_path(workspace, other_user))
               |> json_response(400)
    end
  end

  defp active_thread_summaries_path(workspace, user) do
    "/api/workspaces/#{workspace.id}/users/#{user.id}/active-thread-summaries"
  end

  defp thread_summaries_path(workspace, user) do
    "/api/workspaces/#{workspace.id}/users/#{user.id}/thread-summaries"
  end

  defp insert_workspace(attrs \\ %{}) do
    %Workspace{}
    |> Workspace.changeset(
      Map.merge(
        %{
          slug: "test",
          name: "Test",
          logo_url: "https://example.com/logo.png",
          status: :active,
          inserted_by: "test",
          updated_by: "test"
        },
        attrs
      )
    )
    |> Repo.insert!()
  end

  defp insert_user(workspace, attrs \\ %{}) do
    %User{}
    |> User.changeset(
      Map.merge(
        %{
          workspace_id: workspace.id,
          email: "user@example.com",
          first_name: "Test",
          last_name: "User",
          handle: "user",
          inserted_by: "test",
          updated_by: "test"
        },
        attrs
      )
    )
    |> Repo.insert!()
  end

  defp insert_thread(workspace, attrs) do
    %Thread{}
    |> Thread.changeset(
      Map.merge(
        %{
          workspace_id: workspace.id,
          name: "Thread",
          inserted_by: "test",
          updated_by: "test"
        },
        attrs
      )
    )
    |> Repo.insert!()
  end

  defp insert_thread_member(thread, user, attrs \\ %{}) do
    %ThreadMember{}
    |> ThreadMember.changeset(
      Map.merge(
        %{
          workspace_id: thread.workspace_id,
          thread_id: thread.id,
          user_id: user.id,
          inserted_by: "test",
          updated_by: "test"
        },
        attrs
      )
    )
    |> Repo.insert!()
  end
end
