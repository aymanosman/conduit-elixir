defmodule Conduit.Content do
  import Conduit.Security, only: [verified: 2]
  alias Conduit.Content.{Article, Comment}

  def list_articles(maybe_token, attrs) do
    if maybe_token do
      verified(maybe_token, fn %{"sub" => user_id} -> Article.list(user_id, attrs) end)
    else
      Article.list(nil, attrs)
    end
  end

  def create_article(token, attrs) do
    verified(token, fn %{"sub" => user_id} -> Article.create(user_id, attrs) end)
  end

  def add_comment(token, slug, attrs) do
    verified(token, fn %{"sub" => user_id} -> Comment.add(user_id, slug, attrs) end)
  end
end
