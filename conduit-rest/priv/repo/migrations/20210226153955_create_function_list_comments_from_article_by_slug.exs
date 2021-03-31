defmodule Conduit.Repo.Migrations.CreateFunctionListCommentsFromArticleBySlug do
  use Ecto.Migration

  @list_comments_from_article_by_slug File.read!(
                                        Application.app_dir(
                                          :conduit,
                                          "priv/repo/sql/list_comments_from_article_by_slug.sql"
                                        )
                                      )

  def change do
    execute(
      @list_comments_from_article_by_slug,
      "drop function list_comments_from_article_by_slug"
    )
  end
end
