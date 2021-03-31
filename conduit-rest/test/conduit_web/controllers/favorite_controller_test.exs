defmodule ConduitWeb.FavoriteControllerTest do
  use ConduitWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "favorite" do
    test "succeeds if authenticated", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, article} = article_fixture(jack.token, %{title: "How to train dragons"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> post(Routes.favorite_path(conn, :favorite, article.slug))

      assert %{"article" => %{"favorited" => true}} = json_response(conn, 200)
    end
  end

  describe "unfavorite" do
    test "succeeds if authenticated", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, article} = article_fixture(jack.token, %{title: "How to train dragons"})
      {:ok, _} = Conduit.Content.favorite_article_by_slug(jack.token, article.slug)

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> delete(Routes.favorite_path(conn, :unfavorite, article.slug))

      assert %{"article" => %{"favorited" => false}} = json_response(conn, 200)
    end
  end
end
