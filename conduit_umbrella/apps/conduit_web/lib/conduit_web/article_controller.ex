defmodule ConduitWeb.ArticleController do
  import Plug.Conn

  def list(conn) do
    maybe_token =
      case get_req_header(conn, "authorization") do
        ["Token " <> token] -> token
        _ -> nil
      end

    with {:ok, articles, count} <- Conduit.Content.list_articles(maybe_token, conn.query_params) do
      conn
      |> view_articles(articles, count)
    else
      {:error, reason} ->
        raise reason
    end
  end

  def create(conn) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, article} <- Conduit.Content.create_article(token, conn.body_params) do
          conn
          |> send_resp(201, Jason.encode!(%{"article" => article}))
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

  defp view_articles(conn, articles, count) do
    conn
    |> send_resp(
      conn.status || 200,
      Jason.encode!(%{"articles" => articles, "articlesCount" => count})
    )
  end
end
