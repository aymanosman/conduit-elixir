defmodule ConduitWeb.UserController do
  use ConduitWeb, :controller

  alias Conduit.Accounts

  action_fallback ConduitWeb.FallbackController

  def register(conn, params) do
    with {:ok, user} <- Accounts.register_user(params["user"] || %{}) do
      conn
      |> put_status(:created)
      |> render("user.json", user: user)
    end
  end

  def authenticate(conn, params) do
    with {:ok, user} <- Accounts.authenticate_user(params["user"] || %{}) do
      render(conn, "user.json", user: user)
    end
  end

  def current(conn, _params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, user} <- Accounts.get_current_user(token) do
          render(conn, "user.json", user: user)
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def update(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, user} <- Accounts.update_user(token, params["user"] || %{}) do
          render(conn, "user.json", user: user)
        end

      _ ->
        {:error, :unauthorized}
    end
  end
end
