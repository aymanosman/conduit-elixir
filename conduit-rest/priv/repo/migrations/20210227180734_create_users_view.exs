defmodule Conduit.Repo.Migrations.CreateUsersView do
  use Ecto.Migration

  @users_view File.read!(
                Application.app_dir(
                  :conduit,
                  "priv/repo/sql/users_view.sql"
                )
              )

  def change do
    execute(
      @users_view,
      "drop view users_view"
    )
  end
end
