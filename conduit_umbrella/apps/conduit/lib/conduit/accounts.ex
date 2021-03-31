defmodule Conduit.Accounts do
  import Conduit.Security, only: [verified: 2]
  alias Conduit.Accounts.User

  def register_user(attrs) do
    User.register(attrs)
  end

  def authenticate_user(attrs) do
    User.authenticate(attrs)
  end

  def current_user(token) do
    verified(token, fn %{"sub" => user_id} -> User.current(user_id) end)
  end

  def update_user(token, attrs) do
    verified(token, fn %{"sub" => user_id} -> User.update(user_id, attrs) end)
  end
end
