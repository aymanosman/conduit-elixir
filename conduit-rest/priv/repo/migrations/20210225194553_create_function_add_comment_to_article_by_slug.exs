defmodule Conduit.Repo.Migrations.CreateFunctionAddCommentToArticleBySlug do
  use Ecto.Migration

  @add_comment_to_article_by_slug File.read!(
                                    Application.app_dir(
                                      :conduit,
                                      "priv/repo/sql/add_comment_to_article_by_slug.sql"
                                    )
                                  )

  def change do
    execute(@add_comment_to_article_by_slug, "drop function add_comment_to_article_by_slug")
  end
end
