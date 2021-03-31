defmodule ConduitWeb.UserView do
  use ConduitWeb, :view

  def render("user.json", %{user: user}) do
    %{user: user}
  end
end
