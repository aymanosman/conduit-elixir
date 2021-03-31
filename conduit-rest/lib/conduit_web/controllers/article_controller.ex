defmodule ConduitWeb.ArticleController do
  use ConduitWeb, :controller

  alias Conduit.Content

  action_fallback ConduitWeb.FallbackController

  def create(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, article} <- Content.create_article(token, params["article"] || %{}) do
          conn
          |> put_status(:created)
          |> render("single.json", article: article)
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def index(conn, params) do
    maybe_token =
      case get_req_header(conn, "authorization") do
        ["Token " <> token] -> token
        _ -> nil
      end

    with {:ok, articles, articles_count} <- Content.list_articles(maybe_token, params) do
      render(conn, "multiple.json", articles: articles, articles_count: articles_count)
    end
  end

  def get(conn, params) do
    maybe_token =
      case get_req_header(conn, "authorization") do
        ["Token " <> token] -> token
        _ -> nil
      end

    with {:ok, article} <- Content.get_article_by_slug(maybe_token, params["slug"]) do
      render(conn, "single.json", article: article)
    end
  end

  def update(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, article} <-
               Content.update_article_by_slug(token, params["slug"], params["article"] || %{}) do
          conn
          |> render("single.json", article: article)
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def delete(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with :ok <-
               Content.delete_article_by_slug(token, params["slug"]) do
          conn
          |> send_resp(200, "")
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def feed(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, articles, count} <-
               Content.feed_articles(token, params) do
          render(conn, "multiple.json", articles: articles, articles_count: count)
        end

      _ ->
        {:error, :unauthorized}
    end
  end
end
