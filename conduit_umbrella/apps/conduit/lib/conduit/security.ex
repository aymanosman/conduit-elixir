defmodule Conduit.Security do
  use Joken.Config

  def verified(token, proc) do
    case verify_and_validate(token) do
      {:ok, claims} ->
        proc.(claims)

      _ ->
        {:error, :unauthorized}
    end
  end
end
