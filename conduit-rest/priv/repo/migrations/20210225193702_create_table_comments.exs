defmodule Conduit.Repo.Migrations.CreateTableComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :text
      add :article_id, references(:articles, on_delete: :delete_all)
      add :author_id, references(:users, on_delete: :delete_all)

      timestamps(inserted_at: :createdAt, updated_at: :updatedAt)
    end
  end
end
