defmodule Conduit.Repo.Migrations.CreateFunctionUnfavoriteArticleBySlug do
  use Ecto.Migration

  @unfavorite_article_by_slug File.read!(
                                Application.app_dir(
                                  :conduit,
                                  "priv/repo/sql/unfavorite_article_by_slug.sql"
                                )
                              )

  def change do
    execute(@unfavorite_article_by_slug, "drop function unfavorite_article_by_slug")
  end
end
