defmodule ConduitWeb.ProfileControllerTest do
  use ConduitWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "get" do
    test "succeeds", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, jill} = user_fixture(%{username: "jill"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jill.token)
        |> get(Routes.profile_path(conn, :get, jack.username))

      assert %{
               "profile" => %{
                 "username" => "jack"
               }
             } = json_response(conn, 200)
    end
  end
end
