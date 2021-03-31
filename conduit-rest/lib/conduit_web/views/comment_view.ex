defmodule ConduitWeb.CommentView do
  use ConduitWeb, :view

  alias ConduitWeb.CommentView

  def render("multiple.json", %{comments: comments}) do
    %{comments: render_many(comments, CommentView, "comment.json")}
  end

  def render("single.json", %{comment: comment}) do
    %{comment: render_one(comment, CommentView, "comment.json")}
  end

  def render("comment.json", %{comment: comment}) do
    comment
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
