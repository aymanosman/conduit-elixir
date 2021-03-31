defmodule Conduit.Accounts.User do
  import Ecto.Changeset

  alias Conduit.Repo
  alias Conduit.Accounts.UserManager

  def register(attrs) do
    changeset = register_changeset(%{}, attrs)

    if changeset.valid? do
      with {:ok, result} <-
             Repo.query(
               "select id, username, email, bio, image from register_user($1, $2::citext, $3, $4, $5)",
               [
                 get_field(changeset, :username),
                 get_field(changeset, :email),
                 get_field(changeset, :password),
                 get_field(changeset, :bio),
                 get_field(changeset, :image)
               ]
             ) do
        from_result(result)
      end
    else
      {:error, changeset}
    end
  end

  def authenticate(attrs) do
    changeset = authenticate_changeset(%{}, attrs)

    if changeset.valid? do
      with {:ok, result} <-
             Repo.query(
               "select * from authenticate_user($1, $2)",
               [
                 get_field(changeset, :email),
                 get_field(changeset, :password)
               ]
             ) do
        from_result(result)
      end
    else
      {:error, changeset}
    end
  end

  def by_id(id) do
    with {:ok, result} <- Repo.query("select * from get_user_by_id($1)", [id]) do
      from_result(result)
    end
  end

  def update_user(id, attrs) do
    changeset = update_changeset(%{}, attrs)

    if changeset.valid? do
      # update_user($1 _id       bigint,
      #             $2 _email    citext,
      #             $3 _bio      text,
      #             $4 _image    text,
      #             $5 _username text,
      #             $6 _password text)
      with {:ok, result} <-
             Repo.query(
               "select * from update_user($1, $2, $3, $4, $5, $6)",
               [
                 id,
                 get_field(changeset, :email),
                 get_field(changeset, :bio),
                 get_field(changeset, :image),
                 get_field(changeset, :username),
                 get_field(changeset, :password)
               ]
             ) do
        from_result(result)
      end
    else
      {:error, changeset}
    end
  end

  @types %{
    username: :string,
    email: :string,
    password: :string,
    bio: :string,
    image: :string
  }

  def register_changeset(%{}, attrs) do
    cast({%{}, @types}, attrs, [:username, :email, :password, :bio, :image])
    |> validate_required([:username, :email, :password])
  end

  def authenticate_changeset(%{}, attrs) do
    cast({%{}, @types}, attrs, [:email, :password])
    |> validate_required([:email, :password])
  end

  def update_changeset(%{}, attrs) do
    cast({%{}, @types}, attrs, [:username, :email, :password, :bio, :image])
  end

  def from_result(%Postgrex.Result{columns: columns, rows: [[id | _] = row]}) do
    if id do
      {:ok, from_row(columns, row)}
    else
      {:error, :not_found}
    end
  end

  def from_row(columns, row) do
    Stream.zip([columns, row])
    |> Stream.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
    |> Enum.into(%{})
    |> put_token()
    |> Map.delete(:id)
  end

  defp put_token(map) do
    with {:ok, token, _claims} <- UserManager.generate_and_sign(%{"sub" => map[:id]}) do
      Map.put(map, :token, token)
    end
  end
end
