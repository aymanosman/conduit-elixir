defmodule Conduit.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :tag, :text, null: false
      add :article_id, references(:articles, on_delete: :delete_all)
    end

    create unique_index(:tags, [:tag, :article_id])

    create index(:tags, [:tag])
    create index(:tags, [:article_id])
  end
end
