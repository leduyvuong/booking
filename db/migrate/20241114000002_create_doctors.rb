class CreateDoctors < ActiveRecord::Migration[7.1]
  def change
    create_table :doctors do |t|
      t.references :clinic, null: false, foreign_key: true
      t.string :name, null: false
      t.string :specialty, null: false
      t.text :bio
      t.string :avatar_url

      t.timestamps
    end
  end
end
