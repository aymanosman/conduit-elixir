defmodule ConduitWeb.CommentControllerTest do
  use ConduitWeb.ConnCase, async: true

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "add" do
    test "succeeds when user is authenticated", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, article} = article_fixture(jack.token, %{title: "How to train dragons"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> post(
          Routes.comment_path(conn, :add, article.slug),
          %{
            comment: %{
              body: "Nice article!"
            }
          }
        )

      assert %{
               "comment" => %{
                 "body" => "Nice article!",
                 "author" => %{
                   "username" => "jack"
                 }
               }
             } = json_response(conn, 201)
    end
  end

  describe "delete" do
    test "succeeds if authenticated", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, article} = article_fixture(jack.token, %{title: "How to train dragons"})

      {:ok, comment} =
        Conduit.Content.add_comment(jack.token, article.slug, %{body: "Nice article!"})

      conn =
        conn
        |> put_req_header("authorization", "Token " <> jack.token)
        |> delete(Routes.comment_path(conn, :delete, article.slug, comment.id))

      assert conn.status == 200
    end
  end

  describe "list" do
    test "succeeds", %{conn: conn} do
      {:ok, jack} = user_fixture(%{username: "jack"})
      {:ok, article} = article_fixture(jack.token, %{title: "How to train dragons"})

      {:ok, _} = Conduit.Content.add_comment(jack.token, article.slug, %{body: "Nice article!"})
      {:ok, _} = Conduit.Content.add_comment(jack.token, article.slug, %{body: "Nice article!"})
      {:ok, _} = Conduit.Content.add_comment(jack.token, article.slug, %{body: "Nice article!"})

      conn =
        conn
        |> get(Routes.comment_path(conn, :list, article.slug))

      assert %{
               "comments" => [%{"body" => "Nice article!"}, _, _]
             } = json_response(conn, 200)
    end
  end
end
