defmodule ConduitWeb.UserControllerTest do
  use ConduitWeb.ConnCase, async: true

  alias Conduit.Accounts

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register" do
    test "registering a user fails if missing email", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :register),
          %{
            user: %{
              username: "jack",
              password: "pass"
            }
          }
        )

      assert json_response(conn, 422)["errors"] == %{"email" => ["can't be blank"]}
    end

    test "register a user", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :register),
          %{
            user: %{
              username: "jack",
              email: "jack@jack",
              password: "pass"
            }
          }
        )

      assert %{
               "username" => "jack",
               "email" => "jack@jack",
               "bio" => nil,
               "image" => nil
             } ==
               json_response(conn, 201)["user"]
               |> Map.delete("token")
    end
  end

  describe "authenticate" do
    test "authenticate fails when given wrong credentials", %{conn: conn} do
      {:ok, _} = Accounts.register_user(%{username: "jack", email: "jack@jack", password: "pass"})

      conn =
        post(
          conn,
          Routes.user_path(conn, :authenticate),
          %{
            user: %{
              email: "jack@jack",
              password: "wrongpass"
            }
          }
        )

      assert %{"errors" => %{}} == json_response(conn, 404)
    end

    test "authenticate succeeds when given correct credentials", %{conn: conn} do
      {:ok, _} = Accounts.register_user(%{username: "jack", email: "jack@jack", password: "pass"})

      conn =
        post(
          conn,
          Routes.user_path(conn, :authenticate),
          %{
            user: %{
              email: "jack@jack",
              password: "pass"
            }
          }
        )

      assert %{
               "username" => "jack",
               "email" => "jack@jack",
               "bio" => nil,
               "image" => nil
             } ==
               json_response(conn, 200)["user"]
               |> Map.delete("token")
    end
  end

  describe "get current user" do
    test "succeeds with token", %{conn: conn} do
      {:ok, jack} =
        Accounts.register_user(%{username: "jack", email: "jack@jack", password: "pass"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> get(Routes.user_path(conn, :current))

      assert %{
               "username" => "jack",
               "email" => "jack@jack",
               "bio" => nil,
               "image" => nil
             } ==
               json_response(conn, 200)["user"]
               |> Map.delete("token")
    end

    test "fails without token", %{conn: conn} do
      conn =
        conn
        |> get(Routes.user_path(conn, :current))

      assert %{"errors" => %{}} == json_response(conn, 401)
    end

    test "fails with invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Token garbage")
        |> get(Routes.user_path(conn, :current))

      assert %{"errors" => %{}} == json_response(conn, 401)
    end
  end

  describe "update user" do
    test "succeeds with token", %{conn: conn} do
      {:ok, jack} =
        Accounts.register_user(%{username: "jack", email: "jack@jack", password: "pass"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> put(Routes.user_path(conn, :update), %{user: %{email: "new@jack"}})

      assert %{
               "username" => "jack",
               "email" => "new@jack",
               "bio" => nil,
               "image" => nil
             } ==
               json_response(conn, 200)["user"]
               |> Map.delete("token")
    end
  end
end
