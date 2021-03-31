defmodule Conduit.Content.Article do
  import Ecto.Changeset

  alias Conduit.Repo

  # So String.to_existing_atom works
  def article_fields() do
    [:createdAt, :updatedAt, :favorited, :favoritesCount]
  end

  def create_article(user_id, attrs) do
    changeset = changeset(%{}, attrs)

    if changeset.valid? do
      # create_article($1 self bigint,
      #                $2 _title text,
      #                $3 _description text,
      #                $4 _body text,
      #                $5 _tagList text array)
      with {:ok, result} <-
             Repo.query(
               "select * from create_article($1, $2, $3, $4, $5)",
               [
                 user_id,
                 get_field(changeset, :title),
                 get_field(changeset, :description),
                 get_field(changeset, :body),
                 get_field(changeset, :tagList)
               ]
             ) do
        one(result)
      end
    else
      {:error, changeset}
    end
  end

  def update_article_by_slug(user_id, slug, attrs) do
    changeset = update_changeset(%{}, attrs)

    if changeset.valid? do
      # update_article_by_slug($1 user_id bigint,
      #                        $2 _slug text,
      #                        $3 _title text,
      #                        $4 _description text,
      #                        $5 _body text,
      #                        $6 _tagList text[])
      with {:ok, result} <-
             Repo.query(
               "select * from update_article_by_slug($1, $2, $3, $4, $5, $6)",
               [
                 user_id,
                 slug,
                 get_field(changeset, :title),
                 get_field(changeset, :description),
                 get_field(changeset, :body),
                 get_field(changeset, :tagList)
               ]
             ) do
        one(result)
      end
    else
      {:error, changeset}
    end
  end

  def get_article_by_slug(user_id, slug) do
    with {:ok, result} <- Repo.query("select * from get_article_by_slug($1, $2)", [slug, user_id]) do
      one(result)
    end
  end

  def delete_article_by_slug(user_id, slug) do
    with {:ok, %{num_rows: 1, rows: [[deleted]]}} <-
           Repo.query("select * from delete_article_by_slug($1, $2)", [user_id, slug]) do
      if deleted do
        :ok
      else
        {:error, :not_found}
      end
    end
  end

  def count_articles() do
    with {:ok, %Postgrex.Result{rows: [[count]]}} <- Repo.query("select count(*) from articles") do
      {:ok, count}
    end
  end

  def list_articles(user_id, attrs \\ %{}) do
    changeset = list_changeset(%{}, attrs)

    if changeset.valid? do
      cond do
        get_field(changeset, :tag) ->
          with {:ok, result} <-
                 Repo.query(
                   "select * from list_articles_by_tag($1, $2, $3, $4)",
                   [
                     user_id,
                     get_field(changeset, :limit),
                     get_field(changeset, :offset),
                     get_field(changeset, :tag)
                   ]
                 ) do
            from_result(result)
          end

        get_field(changeset, :author) ->
          with {:ok, result} <-
                 Repo.query(
                   "select * from list_articles_by_author_username($1, $2, $3, $4)",
                   [
                     user_id,
                     get_field(changeset, :limit),
                     get_field(changeset, :offset),
                     get_field(changeset, :author)
                   ]
                 ) do
            from_result(result)
          end

        get_field(changeset, :favorited) ->
          with {:ok, result} <-
                 Repo.query(
                   "select * from list_articles_by_favorited_username($1, $2, $3, $4)",
                   [
                     user_id,
                     get_field(changeset, :limit),
                     get_field(changeset, :offset),
                     get_field(changeset, :favorited)
                   ]
                 ) do
            from_result(result)
          end

        true ->
          with {:ok, result} <-
                 Repo.query(
                   "select * from list_articles($1, $2, $3)",
                   [
                     user_id,
                     get_field(changeset, :limit),
                     get_field(changeset, :offset)
                   ]
                 ) do
            from_result(result)
          end
      end
    else
      {:error, changeset}
    end
  end

  def list_articles_by_following(user_id, attrs) do
    changeset = following_changeset(%{}, attrs)

    if changeset.valid? do
      with {:ok, result} <-
             Repo.query(
               "select * from list_articles_by_following($1, $2, $3)",
               [
                 user_id,
                 get_field(changeset, :limit),
                 get_field(changeset, :offset)
               ]
             ) do
        from_result(result)
      end
    else
      {:error, changeset}
    end
  end

  def favorited_article_by_slug(user_id, slug) do
    with {:ok, result} <-
           Repo.query("select * from favorite_article_by_slug($1, $2)", [user_id, slug]) do
      one(result)
    end
  end

  def unfavorited_article_by_slug(user_id, slug) do
    with {:ok, result} <-
           Repo.query("select * from unfavorite_article_by_slug($1, $2)", [user_id, slug]) do
      one(result)
    end
  end

  @types %{
    title: :string,
    description: :string,
    body: :string,
    tagList: {:array, :string}
  }

  def cast_article(article, attrs) do
    cast({article, @types}, attrs, [:title, :description, :body, :tagList])
  end

  def changeset(article, attrs) do
    cast_article(article, attrs)
    |> validate_required([:title, :description, :body])
  end

  def update_changeset(article, attrs) do
    cast_article(article, attrs)
  end

  def list_changeset(%{}, attrs) do
    types = %{
      tag: :string,
      author: :string,
      favorited: :string,
      limit: :integer,
      offset: :integer
    }

    cast({%{}, types}, attrs, [:tag, :author, :favorited, :limit, :offset])
    |> validate_at_most_one_of([:tag, :author, :favorited])
    |> validate_inclusion(:limit, 1..100)
    |> validate_number(:offset, greater_than_or_equal_to: 0)
  end

  def following_changeset(%{}, attrs) do
    types = %{
      limit: :integer,
      offset: :integer
    }

    cast({%{}, types}, attrs, [:limit, :offset])
    |> validate_inclusion(:limit, 1..100)
    |> validate_number(:offset, greater_than_or_equal_to: 0)
  end

  def validate_at_most_one_of(changeset, fields) do
    case fields
         |> Enum.count(fn f -> get_field(changeset, f) end) do
      0 ->
        changeset

      1 ->
        changeset

      _ ->
        add_at_most_one_of_error(changeset, fields)
    end
  end

  defp add_at_most_one_of_error(changeset, fields) do
    fields
    |> Enum.reduce(
      changeset,
      fn f, changeset ->
        add_error(
          changeset,
          f,
          "at most one of ${fields} may be present",
          validation: :at_most_one_of,
          fields: fields
        )
      end
    )
  end

  defp one(result) do
    case from_result(result) do
      {:ok, [], _} ->
        {:error, :not_found}

      {:ok, [thing], _} ->
        {:ok, thing}
    end
  end

  def from_result(%Postgrex.Result{columns: columns, num_rows: num_rows, rows: rows}) do
    {
      :ok,
      rows
      |> Enum.map(fn row -> from_row(columns, row) end),
      num_rows
    }
  end

  def from_row(columns, row) do
    Stream.zip([columns, row])
    |> Stream.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Enum.into(%{})
    |> put_author()
  end

  def put_author(record) do
    record
    |> Map.update!(
      :author,
      fn
        nil ->
          nil

        author ->
          {username, bio, image, following} = author
          %{username: username, bio: bio, image: image, following: following}
      end
    )
  end
end
