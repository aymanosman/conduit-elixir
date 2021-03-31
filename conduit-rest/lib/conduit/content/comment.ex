defmodule Conduit.Content.Comment do
  import Ecto.Changeset

  alias Conduit.Repo
  alias Conduit.Content.Article

  def add_comment(user_id, slug, attrs) when is_binary(slug) do
    changeset = add_changeset(%{}, attrs)

    if changeset.valid? do
      with {:ok, result} <-
             Repo.query(
               "select * from add_comment_to_article_by_slug($1, $2, $3)",
               [
                 user_id,
                 slug,
                 get_field(changeset, :body)
               ]
             ) do
        one(result)
      end
    else
      {:error, changeset}
    end
  end

  def list_comments(user_id, slug) do
    changeset = list_changeset(%{}, %{slug: slug})

    if changeset.valid? do
      with {:ok, result} <-
             Repo.query("select * from list_comments_from_article_by_slug($1, $2)", [
               user_id,
               slug
             ]) do
        from_result(result)
      end
    else
      {:error, changeset}
    end
  end

  def delete_comment(user_id, slug, comment_id) do
    changeset = delete_changeset(%{}, %{id: comment_id})

    if changeset.valid? do
      with {:ok, %{num_rows: 1, rows: [[deleted]]}} <-
             Repo.query(
               "select * from delete_comment_from_article_by_slug($1, $2, $3)",
               [
                 user_id,
                 slug,
                 get_field(changeset, :id)
               ]
             ) do
        if deleted do
          :ok
        else
          {:error, :not_found}
        end
      end
    else
      {:error, changeset}
    end
  end

  @types %{
    id: :integer,
    slug: :string,
    body: :string
  }

  def add_changeset(comment, attrs) do
    cast({comment, @types}, attrs, [:body])
    |> validate_required([:body])
  end

  def list_changeset(comment, attrs) do
    cast({comment, @types}, attrs, [:slug])
    |> validate_required([:slug])
  end

  def delete_changeset(comment, attrs) do
    cast({comment, @types}, attrs, [:id])
    |> validate_required([:id])
  end

  defp one(result) do
    case from_result(result) do
      {:ok, []} ->
        {:error, :not_found}

      {:ok, [thing]} ->
        {:ok, thing}
    end
  end

  def from_result(%Postgrex.Result{columns: columns, rows: rows}) do
    {
      :ok,
      rows
      |> Enum.map(fn row -> from_row(columns, row) end)
    }
  end

  def from_row(columns, row) do
    Stream.zip([columns, row])
    |> Stream.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Enum.into(%{})
    |> Article.put_author()
  end
end
