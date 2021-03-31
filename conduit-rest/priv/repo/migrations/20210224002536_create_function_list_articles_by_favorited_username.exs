defmodule Conduit.Repo.Migrations.CreateFunctionListArticlesByFavoritedUsername do
  use Ecto.Migration

  @list_articles_by_favorited_username File.read!(
                                         Application.app_dir(
                                           :conduit,
                                           "priv/repo/sql/list_articles_by_favorited_username.sql"
                                         )
                                       )

  def change do
    execute(
      @list_articles_by_favorited_username,
      "drop function list_articles_by_favorited_username"
    )
  end
end
