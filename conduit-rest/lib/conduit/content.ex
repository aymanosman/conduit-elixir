defmodule Conduit.Content do
  @moduledoc """
  The Content Context
  """

  import Conduit.Accounts, only: [verified: 2]
  alias Conduit.Content.{Article, Comment, Tag}

  def create_article(token, attrs) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Article.create_article(user_id, attrs)
      end
    )
  end

  def get_article_by_slug(maybe_token, slug) do
    if maybe_token do
      verified(
        maybe_token,
        fn %{"sub" => user_id} ->
          Article.get_article_by_slug(user_id, slug)
        end
      )
    else
      Article.get_article_by_slug(nil, slug)
    end
  end

  def update_article_by_slug(token, slug, attrs) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Article.update_article_by_slug(user_id, slug, attrs)
      end
    )
  end

  def delete_article_by_slug(token, slug) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Article.delete_article_by_slug(user_id, slug)
      end
    )
  end

  def count_articles() do
    Article.count_articles()
  end

  def list_articles(maybe_token \\ nil, attrs \\ %{}) do
    if maybe_token do
      verified(
        maybe_token,
        fn %{"sub" => user_id} ->
          Article.list_articles(user_id, attrs)
        end
      )
    else
      Article.list_articles(nil, attrs)
    end
  end

  def favorite_article_by_slug(token, slug) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Article.favorited_article_by_slug(user_id, slug)
      end
    )
  end

  def unfavorite_article_by_slug(token, slug) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Article.unfavorited_article_by_slug(user_id, slug)
      end
    )
  end

  def add_comment(token, slug, attrs) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Comment.add_comment(user_id, slug, attrs)
      end
    )
  end

  def delete_comment(token, slug, comment_id) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Comment.delete_comment(user_id, slug, comment_id)
      end
    )
  end

  def list_comments(maybe_token, slug) do
    if maybe_token do
      verified(
        maybe_token,
        fn %{"sub" => user_id} ->
          Comment.list_comments(user_id, slug)
        end
      )
    else
      Comment.list_comments(nil, slug)
    end
  end

  def list_tags() do
    Tag.list_tags()
  end

  def feed_articles(token, opts \\ %{}) do
    verified(
      token,
      fn %{"sub" => user_id} ->
        Article.list_articles_by_following(user_id, opts)
      end
    )
  end
end
