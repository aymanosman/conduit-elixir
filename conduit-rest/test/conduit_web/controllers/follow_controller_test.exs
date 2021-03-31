defmodule ConduitWeb.FollowControllerTest do
  use ConduitWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "follow" do
    test "succeeds if authenticated", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, jill} = user_fixture(%{username: "jill"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jill.token)
        |> post(Routes.follow_path(conn, :follow, jack.username))

      assert %{
               "profile" => %{
                 "username" => "jack",
                 "following" => true
               }
             } = json_response(conn, 200)
    end
  end

  describe "unfollow" do
    test "succeeds if authenticated", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, jill} = user_fixture(%{username: "jill"})
      {:ok, _} = Conduit.Social.follow(jill.token, jack.username)

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jill.token)
        |> delete(Routes.follow_path(conn, :unfollow, jack.username))

      assert %{
               "profile" => %{
                 "username" => "jack",
                 "following" => false
               }
             } = json_response(conn, 200)
    end
  end
end
