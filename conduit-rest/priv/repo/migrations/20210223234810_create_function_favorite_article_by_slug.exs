defmodule Conduit.Repo.Migrations.CreateFunctionFavoriteArticleBySlug do
  use Ecto.Migration

  @favorite_article_by_slug File.read!(
                              Application.app_dir(
                                :conduit,
                                "priv/repo/sql/favorite_article_by_slug.sql"
                              )
                            )

  def change do
    execute(@favorite_article_by_slug, "drop function favorite_article_by_slug")
  end
end
