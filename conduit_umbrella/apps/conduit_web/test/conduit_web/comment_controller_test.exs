defmodule ConduitWeb.CommentControllerTest do
  use ConduitWeb.ConnCase, async: true

  @opts ConduitWeb.Router.init([])

  test "add comment" do
    jack = user_fixture(%{"username" => "jack"})
    article = article_fixture(jack["token"], %{"title" => "nice article"})

    conn =
      conn(
        :post,
        "/api/articles/#{article["slug"]}/comments",
        %{
          "comment" => %{
            "body" => "Nice article!"
          }
        }
      )
      |> put_req_header("content-type", "application/json")
      |> put_req_header("authorization", "Token " <> jack["token"])
      |> ConduitWeb.Router.call(@opts)

    assert conn.status == 201

    assert %{
             "comment" => %{
               "body" => "Nice article!",
               "author" => %{
                 "username" => "jack"
               }
             }
           } = Jason.decode!(conn.resp_body)
  end
end
