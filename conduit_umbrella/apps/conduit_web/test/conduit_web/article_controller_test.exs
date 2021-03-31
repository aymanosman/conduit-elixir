defmodule ConduitWeb.ArticleControllerTest do
  use ConduitWeb.ConnCase, async: true

  @opts ConduitWeb.Router.init([])

  test "list articles" do
    jack = user_fixture(%{"username" => "jack"})
    _ = article_fixture(jack["token"], %{"title" => "title 1"})
    _ = article_fixture(jack["token"], %{"title" => "title 2"})
    _ = article_fixture(jack["token"], %{"title" => "title 3"})

    conn =
      conn(:get, "/api/articles")
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 200

    assert %{
             "articlesCount" => 3,
             "articles" => [
               %{"slug" => "title-1"},
               %{"slug" => "title-2"},
               %{"slug" => "title-3"}
             ]
           } = Jason.decode!(conn.resp_body)
  end

  test "create article" do
    jack = user_fixture(%{"username" => "jack"})

    conn =
      conn(
        :post,
        "/api/articles",
        Jason.encode!(%{
          "article" => %{
            "title" => "How to train your Dragon",
            "description" => "Ever wondered how?",
            "body" => "It takes a Jacobin",
            "tagList" => ["myth", "dragons"]
          }
        })
      )
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Token " <> jack["token"])
      |> ConduitWeb.Router.call(@opts)

    assert conn.state == :sent
    assert conn.status == 201

    assert %{
             "article" => %{
               "slug" => "how-to-train-your-dragon",
               "title" => "How to train your Dragon",
               "description" => "Ever wondered how?",
               "body" => "It takes a Jacobin",
               "tagList" => tags,
               "author" => %{
                 "username" => "jack"
               }
             }
           } = Jason.decode!(conn.resp_body)

    assert MapSet.new(tags) == MapSet.new(["myth", "dragons"])
  end
end
