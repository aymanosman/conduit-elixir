defmodule Conduit.Repo.Migrations.CreateFunctionDeleteArticleBySlug do
  use Ecto.Migration

  @delete_article_by_slug File.read!(
                            Application.app_dir(
                              :conduit,
                              "priv/repo/sql/delete_article_by_slug.sql"
                            )
                          )

  def change do
    execute(@delete_article_by_slug, "drop function delete_article_by_slug")
  end
end
