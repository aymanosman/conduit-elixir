defmodule Conduit.Repo.Migrations.CreateFunctionListArticlesByTag do
  use Ecto.Migration

  @list_articles_by_tag File.read!(
                          Application.app_dir(
                            :conduit,
                            "priv/repo/sql/list_articles_by_tag.sql"
                          )
                        )

  def change do
    execute(@list_articles_by_tag, "drop function list_articles_by_tag")
  end
end
