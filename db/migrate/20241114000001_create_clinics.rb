class CreateClinics < ActiveRecord::Migration[7.1]
  def change
    create_table :clinics do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.jsonb :opening_hours, null: false, default: {}

      t.timestamps
    end

    add_index :clinics, :name, unique: true
  end
end
