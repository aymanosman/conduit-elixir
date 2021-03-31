defmodule Conduit.Content.Comment do
  def add(user_id, slug, attrs) do
    comment = attrs["comment"]

    with {:ok, result} <-
           Postgrex.query(
             :db,
             "select id,
              body,
              author,
              created_at as \"createdAt\",
              updated_at as \"updatedAt\"
       from content.add_comment($1, $2, $3)",
             [
               user_id,
               slug,
               comment["body"]
             ]
           ) do
      one(result)
    end
  end

  defp one(%Postgrex.Result{num_rows: 1, columns: columns, rows: [row]}) do
    {:ok, from_row(columns, row)}
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
