defmodule GlimeshWeb.UserSessionController do
  use GlimeshWeb, :controller

  alias Glimesh.Tfa
  alias Glimesh.Accounts
  alias GlimeshWeb.UserAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"user" => user_params}) do
    %{"email" => email, "password" => password, "tfa" => tfa} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      if Tfa.validate_pin(tfa, user.tfa_token) do
        UserAuth.log_in_user(conn, user, user_params)
      else
        render(conn, "new.html", error_message: dgettext("errors", "Invalid 2FA Code"))
      end
    else
      render(conn, "new.html", error_message: dgettext("errors", "Invalid e-mail or password"))
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, dgettext("profile", "Logged out successfully."))
    |> UserAuth.log_out_user()
  end
end
