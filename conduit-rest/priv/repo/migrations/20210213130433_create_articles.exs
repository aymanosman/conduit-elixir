defmodule Conduit.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :slug, :text, null: false
      add :title, :text, null: false
      add :description, :text, null: false
      add :body, :text, null: false
      add :author_id, references(:users, on_delete: :delete_all)

      timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
    end

    create unique_index(:articles, [:slug])
  end
end
