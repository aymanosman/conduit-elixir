defmodule Conduit.Social.Follow do
  alias Conduit.Repo

  alias Conduit.Social.Profile

  def follow(id, username) do
    with {:ok, result} <- Repo.query("select * from follow_by_username($1, $2)", [id, username]) do
      Profile.from_result(result)
    end
  end

  def unfollow(id, username) do
    with {:ok, result} <- Repo.query("select * from unfollow_by_username($1, $2)", [id, username]) do
      Profile.from_result(result)
    end
  end
end
