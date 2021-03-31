defmodule ConduitWeb.ProfileView do
  use ConduitWeb, :view

  alias ConduitWeb.ProfileView

  def render("single.json", %{profile: profile}) do
    %{profile: render_one(profile, ProfileView, "profile.json")}
  end

  def render("profile.json", %{profile: profile}) do
    profile
  end
end
