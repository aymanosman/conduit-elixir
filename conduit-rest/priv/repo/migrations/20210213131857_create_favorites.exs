defmodule Conduit.Repo.Migrations.CreateFavorites do
  use Ecto.Migration

  def change do
    create table(:favorites) do
      add :user_id, references(:users)
      add :article_id, references(:articles, on_delete: :delete_all)
    end

    create unique_index(:favorites, [:user_id, :article_id])

    create index(:favorites, [:user_id])
    create index(:favorites, [:article_id])
  end
end
