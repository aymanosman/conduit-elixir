defmodule Conduit.Accounts do
  @moduledoc """
  The Accounts Context
  """

  alias Conduit.Accounts.{UserManager, User}

  def register_user(attrs) do
    User.register(attrs)
  end

  def authenticate_user(attrs) do
    User.authenticate(attrs)
  end

  def get_current_user(token) do
    verified(token, fn %{"sub" => id} -> User.by_id(id) end)
  end

  def update_user(token, attrs) do
    verified(token, fn %{"sub" => id} -> User.update_user(id, attrs) end)
  end

  def verified(token, proc) do
    UserManager.verified(token, proc)
  end
end
