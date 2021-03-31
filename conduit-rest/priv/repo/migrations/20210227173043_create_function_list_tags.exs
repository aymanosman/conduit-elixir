defmodule Conduit.Repo.Migrations.CreateFunctionListTags do
  use Ecto.Migration

  @list_tags File.read!(
               Application.app_dir(
                 :conduit,
                 "priv/repo/sql/list_tags.sql"
               )
             )

  def change do
    execute(
      @list_tags,
      "drop function list_tags"
    )
  end
end
