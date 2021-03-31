defmodule ConduitWeb.TagControllerTest do
  use ConduitWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tags", %{conn: conn} do
      conn = get(conn, Routes.tag_path(conn, :index))
      assert json_response(conn, 200)["tags"] == []
    end
  end
end
