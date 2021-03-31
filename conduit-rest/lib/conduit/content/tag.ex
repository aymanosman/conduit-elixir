defmodule Conduit.Content.Tag do
  alias Conduit.Repo

  def list_tags() do
    with {:ok, result} <- Repo.query("select * from list_tags()") do
      from_result(result)
    end
  end

  defp from_result(%Postgrex.Result{rows: rows}) do
    {
      :ok,
      rows
      |> Enum.flat_map(fn row -> row end)
    }
  end
end
