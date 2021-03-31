defmodule Conduit.Repo.Migrations.CreateTypeComment do
  use Ecto.Migration

  @comment File.read!(
             Application.app_dir(
               :conduit,
               "priv/repo/sql/comment.sql"
             )
           )

  def change do
    execute(@comment, "drop type comment")
  end
end
