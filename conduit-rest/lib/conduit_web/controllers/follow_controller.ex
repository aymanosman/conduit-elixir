defmodule ConduitWeb.FollowController do
  use ConduitWeb, :controller

  alias Conduit.Social

  action_fallback ConduitWeb.FallbackController

  def follow(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, profile} <- Social.follow(token, params["username"]) do
          render(conn, "single.json", profile: profile)
        end

      _ ->
        {:error, :unauthorized}
    end
  end

  def unfollow(conn, params) do
    case get_req_header(conn, "authorization") do
      ["Token " <> token] ->
        with {:ok, profile} <- Social.unfollow(token, params["username"]) do
          render(conn, "single.json", profile: profile)
        end

      _ ->
        {:error, :unauthorized}
    end
  end
end
