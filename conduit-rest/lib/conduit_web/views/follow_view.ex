defmodule ConduitWeb.FollowView do
  use ConduitWeb, :view

  alias ConduitWeb.ProfileView

  def render(template, params) do
    ProfileView.render(template, params)
  end
end
