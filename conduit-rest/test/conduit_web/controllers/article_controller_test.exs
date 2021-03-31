defmodule ConduitWeb.ArticleControllerTest do
  use ConduitWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create" do
    test "succeeds with valid params", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> post(
          Routes.article_path(conn, :create),
          %{
            article: %{
              title: "Some Thing",
              description: "some description",
              body: "some body"
            }
          }
        )

      assert %{
               "title" => "Some Thing",
               "body" => "some body",
               "author" => %{
                 "username" => "jack"
               }
             } = json_response(conn, 201)["article"]
    end
  end

  describe "index" do
    test "list all articles", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index))
      assert json_response(conn, 200)["articles"] == []
    end

    test "list articles by author", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, jill} = user_fixture(%{username: "jill"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-1"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-2"})
      {:ok, _} = article_fixture(jill.token, %{title: "title-3"})

      conn = get(conn, Routes.article_path(conn, :index), %{author: "jack"})

      assert %{"articles" => articles, "articlesCount" => articles_count} =
               json_response(conn, 200)

      assert Enum.count(articles) == 2
      assert articles_count == 2

      assert Enum.all?(
               articles,
               fn
                 %{
                   "author" => %{
                     "username" => "jack"
                   }
                 } ->
                   true

                 _ ->
                   false
               end
             )
    end

    test "list articles by author returns [] when author does not exist", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index), %{author: "noone"})
      assert json_response(conn, 200)["articles"] == []
    end
  end

  describe "get" do
    test "succeeds without authentication", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-1"})

      conn = conn |> get(Routes.article_path(conn, :get, "title-1"))

      assert %{"article" => %{"title" => "title-1"}} = json_response(conn, 200)
    end

    test "succeeds with authentication", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-1"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> get(Routes.article_path(conn, :get, "title-1"))

      assert %{"article" => %{"title" => "title-1"}} = json_response(conn, 200)
    end
  end

  describe "update" do
    test "succeeds when authorized", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-1"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> put(Routes.article_path(conn, :update, "title-1"), %{article: %{title: "title-2"}})

      assert %{"article" => %{"title" => "title-2"}} = json_response(conn, 200)
    end
  end

  describe "delete" do
    test "succeeds when authenticated", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-1"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> delete(Routes.article_path(conn, :delete, "title-1"))

      assert conn.status == 200
      assert conn.resp_body == ""
    end
  end

  describe "feed" do
    test "succeeds", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, jill} = user_fixture(%{username: "jill"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-1"})
      {:ok, _} = article_fixture(jack.token, %{title: "title-2"})
      {:ok, _} = article_fixture(jill.token, %{title: "title-3"})

      {:ok, _} = Conduit.Social.follow(jill.token, jack.username)

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jill.token)
        |> get(Routes.article_path(conn, :feed))

      assert %{"articles" => [_, _]} = json_response(conn, 200)
    end
  end
end
