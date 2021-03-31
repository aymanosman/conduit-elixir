defmodule Conduit.Repo.Migrations.CreateArticlesView do
  use Ecto.Migration

  @articles_view File.read!(
                   Application.app_dir(
                     :conduit,
                     "priv/repo/sql/articles_view.sql"
                   )
                 )

  def change do
    execute(
      @articles_view,
      "drop view articles_view"
    )
  end
end
