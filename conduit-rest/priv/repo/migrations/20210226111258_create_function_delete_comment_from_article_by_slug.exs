defmodule Conduit.Repo.Migrations.CreateFunctionDeleteCommentFromArticleBySlug do
  use Ecto.Migration

  @delete_comment_from_article_by_slug File.read!(
                                         Application.app_dir(
                                           :conduit,
                                           "priv/repo/sql/delete_comment_from_article_by_slug.sql"
                                         )
                                       )

  def change do
    execute(
      @delete_comment_from_article_by_slug,
      "drop function delete_comment_from_article_by_slug"
    )
  end
end
