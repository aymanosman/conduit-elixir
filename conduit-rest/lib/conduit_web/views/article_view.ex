defmodule ConduitWeb.ArticleView do
  use ConduitWeb, :view

  alias ConduitWeb.ArticleView

  def render("multiple.json", %{articles: articles, articles_count: articles_count}) do
    %{articles: render_many(articles, ArticleView, "article.json"), articlesCount: articles_count}
  end

  def render("single.json", %{article: article}) do
    %{article: render_one(article, ArticleView, "article.json")}
  end

  def render("article.json", %{article: article}) do
    article
    |> Map.update!(:createdAt, &truncate_datetime/1)
    |> Map.update!(:updatedAt, &truncate_datetime/1)
  end

  defp truncate_datetime(datetime) do
    DateTime.from_naive!(
      NaiveDateTime.truncate(datetime, :millisecond),
      "Etc/UTC"
    )
  end
end
