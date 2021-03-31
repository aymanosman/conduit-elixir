defmodule Conduit.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :source, references(:users, on_delete: :delete_all)
      add :target, references(:users, on_delete: :delete_all)
    end

    create unique_index(:follows, [:source, :target])
  end
end
