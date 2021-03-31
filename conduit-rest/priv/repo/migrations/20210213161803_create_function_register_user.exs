defmodule Conduit.Repo.Migrations.CreateFunctionRegisterUser do
  use Ecto.Migration

  @conduit_user File.read!(Application.app_dir(:conduit, "priv/repo/sql/conduit_user.sql"))
  @register_user File.read!(Application.app_dir(:conduit, "priv/repo/sql/register_user.sql"))

  def change do
    execute @conduit_user, "drop type conduit_user"
    execute(@register_user, "drop function register_user")
  end
end
