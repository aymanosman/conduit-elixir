defmodule Conduit.Repo.Migrations.CreateFunctionsFollowAndUnfollow do
  use Ecto.Migration

  @follow_by_username File.read!(
                        Application.app_dir(:conduit, "priv/repo/sql/follow_by_username.sql")
                      )
  @unfollow_by_username File.read!(
                          Application.app_dir(:conduit, "priv/repo/sql/unfollow_by_username.sql")
                        )

  def change do
    execute(@follow_by_username, "drop function follow_by_username")
    execute(@unfollow_by_username, "drop function unfollow_by_username")
  end
end
