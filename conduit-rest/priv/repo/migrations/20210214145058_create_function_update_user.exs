defmodule Conduit.Repo.Migrations.CreateFunctionUpdateUser do
  use Ecto.Migration

  @update_user File.read!(Application.app_dir(:conduit, "priv/repo/sql/update_user.sql"))

  def change do
    execute @update_user, "drop function update_user"
  end
end
