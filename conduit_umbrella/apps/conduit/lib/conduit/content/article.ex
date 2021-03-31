defmodule Conduit.Content.Article do

  def list(user_id, attrs) do
    with {:ok, result} <-
           Postgrex.query(:db, "select * from content.list_articles($1, $2, $3)", [
             user_id,
             attrs["limit"],
             attrs["offset"]
           ]) do
      from_result(result)
    end
  end

  def create(user_id, attrs) do
    article = attrs["article"]

    with {:ok, result} <-
           Postgrex.query(
             :db,
             "select slug,
                     title,
                     description,
                     body,
                     tag_list as \"tagList\",
                     author
              from content.create_article($1, $2, $3, $4, $5)",
             [
               user_id,
               article["title"],
               article["description"],
               article["body"],
               article["tagList"]
             ]
           ) do
      one(result)
    end
  end

  defp one(result) do
    case from_result(result) do
      {:ok, [], _} -> raise RuntimeError, "expected one, got none"
      {:ok, [x], _} -> {:ok, x}
      {:ok, _, _} -> raise RuntimeError, "expected one, got many"
    end
  end

  defp from_result(%Postgrex.Result{columns: columns, num_rows: num_rows, rows: rows}) do
    {:ok, rows |> Enum.map(&from_row(columns, &1)), num_rows}
  end

  def from_row(columns, row) do
    Stream.zip([columns, row])
    |> Enum.into(%{})
    |> put_author()
  end

  def put_author(record) do
    record
    |> Map.update!(
      "author",
      fn
        nil ->
          nil

        author ->
          {username, bio, image, following} = author
          %{"username" => username, "bio" => bio, "image" => image, "following" => following}
      end
    )
  end
end
