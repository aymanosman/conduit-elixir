defmodule ConduitWeb.UserController do
  import Plug.Conn

  def register(conn) do
    with {:ok, user} <- Conduit.Accounts.register_user(conn.body_params) do
      conn
      |> put_status(201)
      |> view_user(user)
    else
      {:error, %Postgrex.Error{} = reason} ->
        case describe_postgres_error(reason) do
          {:ok, errors} ->
            conn
            |> put_resp_header("content-type", "application/json")
            |> send_resp(400, Jason.encode!(%{"errors" => errors}))

          _ ->
            raise reason
        end

      {:error, reason} ->
        raise reason
    end
  end

  def authenticate(conn) do
    with {:ok, user} <- Conduit.Accounts.authenticate_user(conn.body_params) do
      view_user(conn, user)
    else
      {:error, :unauthorized} ->
        conn |> send_resp(403, "Forbidden")

      {:error, reason} ->
        raise reason
    end
  end

  def current(conn) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, user} <- Conduit.Accounts.current_user(token) do
          view_user(conn, user)
        else
          {:error, :unauthorized} ->
            conn
            |> send_resp(403, "")

          {:error, reason} ->
            raise reason
        end

      _ ->
        conn
        |> send_resp(401, "")
    end
  end

  def update(conn) do
    with_token_handle_error(conn, fn token ->
      with {:ok, user} <- Conduit.Accounts.update_user(token, conn.body_params) do
        view_user(conn, user)
      end
    end)
  end

  defp with_token_handle_error(conn, proc) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        case proc.(token) do
          %Plug.Conn{} = conn ->
            conn

          {:error, %Postgrex.QueryError{} = _error} ->
            conn |> send_resp(500, "Internal Server Error (C003)")

          {:error, :unauthorized} ->
            conn
            |> send_resp(403, "")

          {:error, reason} ->
            raise reason
        end

      _ ->
        conn
        |> send_resp(401, "")
    end
  end

  defp view_user(conn, user) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(conn.status || 200, Jason.encode!(%{"user" => user}))
  end

  defp describe_postgres_error(%Postgrex.Error{
         postgres: %{
           code: :not_null_violation,
           column: column
         }
       }) do
    {:ok, %{column => "can't be empty"}}
  end

  defp describe_postgres_error(%Postgrex.Error{
         postgres: %{
           code: :unique_violation,
           constraint: "users_username_index"
         }
       }) do
    {:ok, %{"username" => "username already taken"}}
  end

  defp describe_postgres_error(_) do
    :unknown
  end
end
