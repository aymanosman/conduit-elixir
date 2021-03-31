defmodule Conduit.Repo.Migrations.CreateFunctionCreateArticle do
  use Ecto.Migration

  @article File.read!(Application.app_dir(:conduit, "priv/repo/sql/article.sql"))
  @slugify File.read!(Application.app_dir(:conduit, "priv/repo/sql/slugify.sql"))
  @favorited File.read!(Application.app_dir(:conduit, "priv/repo/sql/favorited.sql"))
  @get_article_by_id File.read!(
                       Application.app_dir(:conduit, "priv/repo/sql/get_article_by_id.sql")
                     )
  @create_article File.read!(Application.app_dir(:conduit, "priv/repo/sql/create_article.sql"))

  def change do
    execute(@article, "drop type article")
    execute(@slugify, "drop function _slugify")
    execute(@favorited, "drop function favorited")
    execute(@get_article_by_id, "drop function _get_article_by_id")
    execute(@create_article, "drop function create_article")
  end
end
