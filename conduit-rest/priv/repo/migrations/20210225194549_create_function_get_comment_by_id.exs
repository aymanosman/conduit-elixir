defmodule Conduit.Repo.Migrations.CreateFunctionGetCommentById do
  use Ecto.Migration

  @get_comment_by_id File.read!(
                       Application.app_dir(
                         :conduit,
                         "priv/repo/sql/get_comment_by_id.sql"
                       )
                     )

  def change do
    execute(@get_comment_by_id, "drop function get_comment_by_id")
  end
end
