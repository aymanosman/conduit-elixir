defmodule Conduit.Repo.Migrations.CreateFunctionAuthenticateUser do
  use Ecto.Migration

  @get_user_by_id File.read!(Application.app_dir(:conduit, "priv/repo/sql/get_user_by_id.sql"))
  @authenticate_user File.read!(
                       Application.app_dir(:conduit, "priv/repo/sql/authenticate_user.sql")
                     )

  def change do
    execute @get_user_by_id, "drop function get_user_by_id"
    execute @authenticate_user, "drop function authenticate_user"
  end
end
