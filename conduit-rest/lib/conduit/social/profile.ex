defmodule Conduit.Social.Profile do
  alias Conduit.Repo

  @doc """
    by_username("celeb_", token.sub)
  """
  def by_username(username, self_id) do
    with {:ok, result} <-
           Repo.query("select * from get_profile_by_username($1, $2)", [username, self_id]) do
      from_result(result)
    end
  end

  def from_result(%Postgrex.Result{rows: [[username, bio, image, following?]]}) do
    if username do
      profile =
        %{username: username, bio: bio, image: image}
        |> put_following?(following?)

      {:ok, profile}
    else
      {:error, :not_found}
    end
  end

  defp put_following?(profile, nil) do
    profile
  end

  defp put_following?(profile, following?) do
    profile
    |> Map.put(:following, following?)
  end
end
