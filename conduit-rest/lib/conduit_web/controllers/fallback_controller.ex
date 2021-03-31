defmodule ConduitWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ConduitWeb, :controller

  import Ecto.Changeset

  def call(conn, {:error, %Postgrex.Error{postgres: %{code: :no_data_found}}}) do
    conn
    |> send_resp(404, "")
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ConduitWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    changeset = change({%{}, %{}})

    conn
    |> put_status(:not_found)
    |> put_view(ConduitWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :unauthorized}) do
    changeset = change({%{}, %{}})

    conn
    |> put_status(:unauthorized)
    |> put_view(ConduitWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end
end
