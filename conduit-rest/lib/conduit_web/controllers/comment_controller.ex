defmodule ConduitWeb.CommentController do
  use ConduitWeb, :controller

  alias Conduit.Content

  action_fallback ConduitWeb.FallbackController

  def add(conn, params) do
    case conn |> get_req_header("authorization") do
      ["Token " <> token] ->
        with {:ok, comment} <-
               Content.add_comment(token, params["slug"], params["comment"] || %{}) do
          conn
          |> put_status(:created)
          |> render("single.json", comment: comment)
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def delete(conn, params) do
    case conn |> get_req_header("authorization") do
      ["Token " <> token] ->
        with :ok <-
               Content.delete_comment(token, params["slug"], params["id"]) do
          conn
          |> send_resp(200, "")
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def list(conn, params) do
    maybe_token =
      case get_req_header(conn, "authorization") do
        ["Token " <> token] -> token
        _ -> nil
      end

    with {:ok, comments} <- Content.list_comments(maybe_token, params["slug"]) do
      render(conn, "multiple.json", comments: comments)
    end
  end
end
