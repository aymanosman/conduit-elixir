defmodule ConduitWeb.TagController do
  use ConduitWeb, :controller

  alias Conduit.Content

  action_fallback ConduitWeb.FallbackController

  def index(conn, _params) do
    {:ok, tags} = Content.list_tags()
    render(conn, "index.json", tags: tags)
  end
end
