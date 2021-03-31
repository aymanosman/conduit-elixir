defmodule Conduit.Accounts.User do
  require Logger
  alias Conduit.Security

  def register(attrs) do
    user = attrs["user"]

    with {:ok, result} <-
           Postgrex.query(
             :db,
             "select id, username, email::text, bio, image from accounts.register_user($1, $2, $3, $4, $5)",
             [
               user["username"],
               user["email"],
               user["password"],
               user["bio"],
               user["image"]
             ]
           ) do
      one(result)
    end
  end

  def authenticate(attrs) do
    user = attrs["user"]

    Logger.debug(fn -> "params: #{inspect(user)}" end)

    with {:ok, result} <-
           Postgrex.query(
             :db,
             "select id, username, email::text, bio, image from accounts.authenticate_user($1, $2)",
             [
               user["email"],
               user["password"]
             ]
           ) do
      case from_result(result) do
        {:ok, []} ->
          {:error, :unauthorized}

        {:ok, [x]} ->
          {:ok, x}

        {:ok, _} ->
          raise RuntimeError, "expected at most one result"

        {:error, _} = err ->
          err
      end
    end
  end

  def current(user_id) do
    with {:ok, result} <-
           Postgrex.query(
             :db,
             "select id, username, email::text, bio, image from accounts.get_user_by_id($1)",
             [user_id]
           ) do
      one(result)
    end
  end

  def update(user_id, attrs) do
    user = attrs["user"]

    Logger.debug(fn -> "params: #{inspect(user)}" end)

    with {:ok, result} <-
           Postgrex.query(
             :db,
             "select id, username, email::text, bio, image from accounts.update_user($1, $2, $3, $4, $5, $6)",
             [
               user_id,
               user["email"],
               user["bio"],
               user["image"],
               user["username"],
               user["password"]
             ]
           ) do
      one(result)
    end
  end

  defp one(result) do
    case from_result(result) do
      {:ok, []} -> raise RuntimeError, "expected one, got none"
      {:ok, [x]} -> {:ok, x}
      {:ok, _} -> raise RuntimeError, "expected one, got many"
    end
  end

  defp from_result(%Postgrex.Result{columns: columns, rows: rows}) do
    {:ok, rows |> Enum.map(&from_row(columns, &1))}
  end

  def from_row(columns, row) do
    Stream.zip([columns, row])
    |> Enum.into(%{})
    |> put_token()
    |> Map.delete("id")
  end

  defp put_token(user) do
    with {:ok, token, _claims} <-
           Security.generate_and_sign(%{
             "sub" => user["id"] || raise(RuntimeError, "no user id found")
           }) do
      Map.put(user, "token", token)
    end
  end
end
