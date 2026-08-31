# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Legato.Repo.insert!(%Legato.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
require Logger
alias Legato.Repo
alias Legato.Chat.Schemas.{Thread, ThreadMember, ThreadMessage, User, Workspace, Zap}

Logger.info("Mix.env() == #{Mix.env()}")
if Mix.env() != :dev do
  Mix.raise("SAFETY GUARD: seeds.exs is only enabled in dev!")
end

# =============================================
# Workspace
workspace =
  Repo.get_by(Workspace, slug: "legato") ||
    Repo.insert!(%Workspace{
      slug: "legato",
      name: "Legato",
      logo_url: "https://api.dicebear.com/10.x/glyphs/svg?glyphColor=c4443f,c67a2c,b8542f,c43f7a,a8842c&seed=LegatoChat",
      status: :active,
      inserted_by: "seeds",
      updated_by: "seeds"
    })

add_user = fn(email, handle, first_name, last_name) ->
  Repo.get_by(User, email: email) ||
    Repo.insert!(%User{
      workspace_id: workspace.id,
      email: email,
      first_name: first_name,
      last_name: last_name,
      handle: handle,
      inserted_by: "seeds",
      updated_by: "seeds"
    })
end

add_thread = fn(name) ->
  Repo.get_by(Thread, name: name, workspace_id: workspace.id) ||
    Repo.insert!(%Thread{
      workspace_id: workspace.id,
      name: name,
      inserted_by: "seeds",
      updated_by: "seeds"
    })
end

add_thread_member = fn(thread, user) ->
  Repo.get_by(ThreadMember, workspace_id: workspace.id, thread_id: thread.id, user_id: user.id) ||
    Repo.insert!(%ThreadMember{
      workspace_id: workspace.id,
      thread_id: thread.id,
      user_id: user.id,
      inserted_by: "seeds",
      updated_by: "seeds"
    })
end

# =============================================
# Users

jatin = add_user.("jatins@hey.com", "Jatin", "Sonavane", "jatins")
alice = add_user.("alice@legato.chat", "Alice", "Allison", "alice")
bruce = add_user.("bruce@legato.chat", "Bruce", "Brown", "bruce")
cathy = add_user.("cathy@legato.chat", "Cathy", "Carson", "cathy")
david = add_user.("david@legato.chat", "David", "Davidovic", "david")
elle =  add_user.("elle@legato.chat", "Elle", "Ellison", "elle")
frank = add_user.("frank@legato.chat", "Frank", "Franken", "frank")
gina =  add_user.("gina@legato.chat", "Gina", "Gershon", "gina")

# =============================================
# Threads (and membership and messages)

thread_inbox_or_work = add_thread.("Should we name it Inbox or Work?")

add_thread_member.(thread_inbox_or_work, jatin)
add_thread_member.(thread_inbox_or_work, bruce)
add_thread_member.(thread_inbox_or_work, david)
add_thread_member.(thread_inbox_or_work, frank)
add_thread_member.(thread_inbox_or_work, gina)


thread_devs_just_wanna = add_thread.("Devs just wanna have fun")

add_thread_member.(thread_devs_just_wanna, jatin)
add_thread_member.(thread_devs_just_wanna, alice)
add_thread_member.(thread_devs_just_wanna, bruce)


thread_themes_on_legato = add_thread.("Themes on Legato")

add_thread_member.(thread_themes_on_legato, jatin)
add_thread_member.(thread_themes_on_legato, cathy)
add_thread_member.(thread_themes_on_legato, david)
add_thread_member.(thread_themes_on_legato, elle)
