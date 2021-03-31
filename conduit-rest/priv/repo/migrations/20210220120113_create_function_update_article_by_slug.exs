defmodule Conduit.Repo.Migrations.CreateFunctionUpdateArticleBySlug do
  use Ecto.Migration

  @update_article_by_slug File.read!(
                            Application.app_dir(
                              :conduit,
                              "priv/repo/sql/update_article_by_slug.sql"
                            )
                          )

  def change do
    execute(@update_article_by_slug, "drop function update_article_by_slug")
  end
end
