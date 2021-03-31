defmodule Conduit.Repo.Migrations.CreateFunctionGetArticleBySlug do
  use Ecto.Migration

  @get_article_by_slug File.read!(
                         Application.app_dir(:conduit, "priv/repo/sql/get_article_by_slug.sql")
                       )

  def change do
    execute(@get_article_by_slug, "drop function get_article_by_slug")
  end
end
