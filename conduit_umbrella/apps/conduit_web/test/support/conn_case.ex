defmodule ConduitWeb.ConnCase do
  use ExUnit.CaseTemplate

  @opts ConduitWeb.Router.init([])

  using do
    quote do
      import Plug.Test
      import Plug.Conn
      import ConduitWeb.ConnCase
    end
  end

  setup do
    :ok =
      DBConnection.Ownership.ownership_checkout(:db,
        post_checkout: fn
          connection_module, connection_state ->
            case connection_module.handle_begin([], connection_state) do
              {:ok, _, connection_state} ->
                {:ok, connection_module, connection_state}

              {_error_or_disconnect, err, connection_state} ->
                {:disconnect, err, connection_module, connection_state}
            end

            {:ok, connection_module, connection_state}
        end,
        pre_checkin: fn
          :checkin, connection_module, connection_state ->
            case connection_module.handle_rollback([], connection_state) do
              {:ok, _, connection_state} ->
                {:ok, connection_module, connection_state}
            end

          _reason, connection_module, connection_state ->
            {:ok, connection_module, connection_state}
        end
      )

    :ok
  end

  def user_fixture(attrs \\ %{}) do
    username = attrs["username"] || "bob"

    user = %{
      "username" => username,
      "email" => attrs["email"] || "#{username}@#{username}",
      "password" => attrs["password"] || "#{username}pass"
    }

    %{status: 201, resp_body: body} =
      Plug.Test.conn(:post, "/api/users", Jason.encode!(%{"user" => user}))
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> ConduitWeb.Router.call(@opts)

    Jason.decode!(body)["user"]
  end

  def article_fixture(token, attrs \\ %{}) do
    title = attrs["title"] || "something"

    article = %{
      "title" => title,
      "description" => attrs["description"] || "#{title} description",
      "body" => attrs["body"] || "#{title} body"
    }

    %{status: 201, resp_body: body} =
      Plug.Test.conn(:post, "/api/articles", Jason.encode!(%{"article" => article}))
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> Plug.Conn.put_req_header("authorization", "Token " <> token)
      |> ConduitWeb.Router.call(@opts)

    Jason.decode!(body)["article"]
  end
end
