defmodule Conduit.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "create extension if not exists citext", ""

    create table(:users) do
      add :username, :text, null: false
      add :email, :citext, null: false
      add :password, :text, null: false
    end

    create unique_index(:users, [:username])
    create unique_index(:users, [:email])
  end
end
