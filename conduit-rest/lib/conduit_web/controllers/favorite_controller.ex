defmodule ConduitWeb.FavoriteController do
  use ConduitWeb, :controller

  alias Conduit.Content

  action_fallback ConduitWeb.FallbackController

  def favorite(conn, params) do
    case conn |> get_req_header("authorization") do
      ["Token " <> token] ->
        with {:ok, article} <- Content.favorite_article_by_slug(token, params["slug"]) do
          conn
          |> render("single.json", article: article)
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def unfavorite(conn, params) do
    case conn |> get_req_header("authorization") do
      ["Token " <> token] ->
        with {:ok, article} <- Content.unfavorite_article_by_slug(token, params["slug"]) do
          conn
          |> render("single.json", article: article)
        end

      _ ->
        {:error, :unauthorized}
    end
  end
end
