defmodule ConduitWeb.ArticleViewTest do
  use ConduitWeb.ConnCase, async: true

  import Phoenix.View

  test "truncates datetime to second" do
    assert render_to_string(
             ConduitWeb.ArticleView,
             "single.json",
             article: %{
               createdAt: ~N[2020-10-10T10:10:10.00000],
               updatedAt: ~N[2020-10-10T10:10:10.00000]
             }
           ) ==
             Jason.encode!(%{
               "article" => %{
                 "createdAt" => "2020-10-10T10:10:10.000Z",
                 "updatedAt" => "2020-10-10T10:10:10.000Z"
               }
             })
  end
end
