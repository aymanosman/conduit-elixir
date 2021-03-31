defmodule ConduitWeb.Router do
  use ConduitWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ConduitWeb do
    pipe_through :api

    # Accounts
    post "/users", UserController, :register
    post "/users/login", UserController, :authenticate
    get "/user", UserController, :current
    put "/user", UserController, :update

    # Social
    get "/profiles/:username", ProfileController, :get
    post "/profiles/:username/follow", FollowController, :follow
    delete "/profiles/:username/follow", FollowController, :unfollow

    # Content
    post "/articles", ArticleController, :create
    get "/articles", ArticleController, :index
    get "/articles/feed", ArticleController, :feed
    get "/articles/:slug", ArticleController, :get
    put "/articles/:slug", ArticleController, :update
    delete "/articles/:slug", ArticleController, :delete
    post "/articles/:slug/comments", CommentController, :add
    delete "/articles/:slug/comments/:id", CommentController, :delete
    get "/articles/:slug/comments", CommentController, :list
    post "/articles/:slug/favorite", FavoriteController, :favorite
    delete "/articles/:slug/favorite", FavoriteController, :unfavorite
    get "/tags", TagController, :index
  end
end
