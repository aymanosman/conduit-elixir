defmodule ConduitWeb.ProfileController do
  use ConduitWeb, :controller

  alias Conduit.Social

  action_fallback ConduitWeb.FallbackController

  def get(conn, params) do
    maybe_token =
      case get_req_header(conn, "authorization") do
        ["Token " <> token] -> token
        _ -> nil
      end

    with {:ok, profile} <- Social.get_profile_by_username(maybe_token, params["username"]) do
      render(conn, "single.json", profile: profile)
    end
  end
end
