defmodule Conduit.Repo.Migrations.CreateFunctionGetProfileByUsername do
  use Ecto.Migration

  @profile File.read!(Application.app_dir(:conduit, "priv/repo/sql/profile.sql"))
  @following File.read!(Application.app_dir(:conduit, "priv/repo/sql/following.sql"))
  @get_profile_by_username File.read!(
                             Application.app_dir(
                               :conduit,
                               "priv/repo/sql/get_profile_by_username.sql"
                             )
                           )

  def change do
    execute(@profile, "drop type profile")
    execute @following, "drop function following"
    execute @get_profile_by_username, "drop function get_profile_by_username"
  end
end
