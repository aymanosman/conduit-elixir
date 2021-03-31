defmodule ConduitWeb.CommentController do
  import Plug.Conn

  def add(conn) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, comment} <-
               Conduit.Content.add_comment(token, conn.params["slug"], conn.body_params) do
          conn
          |> send_resp(201, Jason.encode!(%{"comment" => comment}))
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
end
