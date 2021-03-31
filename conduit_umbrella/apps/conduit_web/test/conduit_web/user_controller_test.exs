defmodule ConduitWeb.UserControllerTest do
  use ConduitWeb.ConnCase, async: true

  @opts ConduitWeb.Router.init([])

  test "register user" do
    conn =
      conn(
        :post,
        "/api/users",
        Jason.encode!(%{
          "user" => %{
            "email" => "jake@jake",
            "password" => "jakepass",
            "username" => "jake"
          }
        })
      )
      |> put_req_header("content-type", "application/json")

    conn = ConduitWeb.Router.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 201

    assert %{
             "user" => %{
               "username" => "jake",
               "token" => _
             }
           } = Jason.decode!(conn.resp_body)
  end

  test "register user fails when email is not supplied" do
    conn =
      conn(
        :post,
        "/api/users",
        Jason.encode!(%{
          "user" => %{
            "password" => "jakepass",
            "username" => "jake"
          }
        })
      )
      |> put_req_header("content-type", "application/json")
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 400

    assert %{
             "errors" => %{
               "email" => "can't be empty"
             }
           } = Jason.decode!(conn.resp_body)
  end

  test "register user fails if username already taken" do
    _ = user_fixture(%{"username" => "jack"})

    conn =
      conn(
        :post,
        "/api/users",
        Jason.encode!(%{
          "user" => %{
            "email" => "fakejack@fake",
            "password" => "jackpass",
            "username" => "jack"
          }
        })
      )
      |> put_req_header("content-type", "application/json")
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 400

    assert %{
             "errors" => %{
               "username" => "username already taken"
             }
           } = Jason.decode!(conn.resp_body)
  end

  test "authenticate user" do
    jack = user_fixture(%{"username" => "jack"})

    conn =
      conn(
        :post,
        "/api/users/login",
        Jason.encode!(%{
          "user" => %{
            "email" => jack["email"],
            "password" => "jackpass"
          }
        })
      )
      |> put_req_header("content-type", "application/json")
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 200

    assert %{
             "user" => %{
               "username" => "jack"
             }
           } = Jason.decode!(conn.resp_body)
  end

  test "authenticate user fails when given wrong credentials" do
    jack = user_fixture(%{"username" => "jack"})

    conn =
      conn(
        :post,
        "/api/users/login",
        Jason.encode!(%{
          "user" => %{
            "email" => jack["email"],
            "password" => "wrongpass"
          }
        })
      )
      |> put_req_header("content-type", "application/json")
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 403
    assert conn.resp_body == "Forbidden"
  end

  test "current user" do
    jack = user_fixture(%{"username" => "jack"})

    conn =
      conn(
        :get,
        "/api/user"
      )
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Token " <> jack["token"])
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 200
    assert %{"user" => %{"username" => "jack"}} = Jason.decode!(conn.resp_body)
  end

  test "update user" do
    jack = user_fixture(%{"username" => "jack"})

    conn =
      conn(
        :put,
        "/api/user",
        Jason.encode!(%{
          "user" => %{
            "bio" => "new bio"
          }
        })
      )
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Token " <> jack["token"])
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 200

    image = jack["image"]
    username = jack["username"]
    email = jack["email"]

    assert %{
             "user" => %{
               "bio" => "new bio",
               "image" => ^image,
               "username" => ^username,
               "email" => ^email,
               "token" => _
             }
           } = Jason.decode!(conn.resp_body)
  end
end
