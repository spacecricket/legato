defmodule Legato.Emails do
  import Swoosh.Email
  alias Legato.{Mailer, User}

  def verify_sign_in(%User{} = user, code) when is_integer(code) do
    new()
    |> to(user.email)
    |> from({"Legato", "legato@legato.chat"})
    |> subject("Your sign-in code is #{code}")
    |> html_body("<h1>Hello #{user.email}</h1><p>Your sign-in code is #{code}</p>")
    |> text_body("Hello #{user.email},\n\nYour sign-in code is #{code}")
    |> Mailer.deliver()
  end
end
