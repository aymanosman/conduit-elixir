defmodule ConduitWeb.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:conduit_web])

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/api/users" do
    ConduitWeb.UserController.register(conn)
  end

  post "/api/users/login" do
    ConduitWeb.UserController.authenticate(conn)
  end

  get "/api/user" do
    ConduitWeb.UserController.current(conn)
  end

  put "/api/user" do
    ConduitWeb.UserController.update(conn)
  end

  get "/api/articles" do
    ConduitWeb.ArticleController.list(conn)
  end

  post "/api/articles" do
    ConduitWeb.ArticleController.create(conn)
  end

  post "/api/articles/:slug/comments" do
    ConduitWeb.CommentController.add(conn)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  def handle_errors(conn, _) do
    send_resp(conn, 500, "Something went wrong")
  end
end
