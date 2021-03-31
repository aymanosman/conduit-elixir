defmodule Conduit.Repo.Migrations.CreateFunctionListArticlesByAuthorUsername do
  use Ecto.Migration

  @list_articles_by_author_username File.read!(
                                      Application.app_dir(
                                        :conduit,
                                        "priv/repo/sql/list_articles_by_author_username.sql"
                                      )
                                    )

  def change do
    execute(@list_articles_by_author_username, "drop function list_articles_by_author_username")
  end
end
