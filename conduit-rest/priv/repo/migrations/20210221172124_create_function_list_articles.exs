defmodule Conduit.Repo.Migrations.CreateFunctionListArticles do
  use Ecto.Migration

  @list_articles File.read!(
                   Application.app_dir(
                     :conduit,
                     "priv/repo/sql/list_articles.sql"
                   )
                 )

  def change do
    execute(@list_articles, "drop function list_articles")
  end
end
