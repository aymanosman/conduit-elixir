defmodule Conduit.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :bio, :text
      add :image, :text
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
