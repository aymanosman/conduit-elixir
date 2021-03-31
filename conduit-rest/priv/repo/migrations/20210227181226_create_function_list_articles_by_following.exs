defmodule Conduit.Repo.Migrations.CreateFunctionListArticlesByFollowing do
  use Ecto.Migration

  @list_articles_by_following File.read!(
                                Application.app_dir(
                                  :conduit,
                                  "priv/repo/sql/list_articles_by_following.sql"
                                )
                              )

  def change do
    execute(
      @list_articles_by_following,
      "drop view list_articles_by_following"
    )
  end
end
