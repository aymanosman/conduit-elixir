defmodule ConduitWeb.FavoriteView do
  use ConduitWeb, :view

  alias ConduitWeb.ArticleView

  def render(template, params) do
    ArticleView.render(template, params)
  end
end
