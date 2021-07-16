defmodule SqlBuilder.Repo.Migrations.CreateWidgets do
  use Ecto.Migration

  def change do
    create table("widgets") do
      add :name, :text, null: false
      add :type, :text, null: false
      add :external_id, :text, null: false
      add :creator_id, :integer, null: false

      timestamps()
    end

    create table("creators") do
      add :name, :text, null: false
      add :type, :text, null: false
      add :external_id, :text, null: false

      timestamps()
    end
  end
end
