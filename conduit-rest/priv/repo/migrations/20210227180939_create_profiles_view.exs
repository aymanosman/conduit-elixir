defmodule Conduit.Repo.Migrations.CreateProfilesView do
  use Ecto.Migration

  @profiles_view File.read!(
                   Application.app_dir(
                     :conduit,
                     "priv/repo/sql/profiles_view.sql"
                   )
                 )

  def change do
    execute(
      @profiles_view,
      "drop view profiles_view"
    )
  end
end
