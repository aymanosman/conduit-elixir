defmodule Conduit.Social do
  @moduledoc """
  The Social Context
  """

  import Conduit.Accounts, only: [verified: 2]
  alias Conduit.Social.{Profile, Follow}

  def get_profile_by_username(maybe_token, username) do
    if maybe_token do
      verified(maybe_token, fn %{"sub" => id} -> Profile.by_username(username, id) end)
    else
      Profile.by_username(username, nil)
    end
  end

  def follow(token, username) do
    verified(token, fn %{"sub" => id} -> Follow.follow(id, username) end)
  end

  def unfollow(token, username) do
    verified(token, fn %{"sub" => id} -> Follow.unfollow(id, username) end)
  end
end
