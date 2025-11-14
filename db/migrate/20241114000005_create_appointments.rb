class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.references :time_slot, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: { to_table: :users }
      t.integer :status, null: false, default: 0
      t.string :patient_name, null: false
      t.string :patient_phone, null: false
      t.string :patient_email, null: false
      t.text :notes
      t.string :booking_number, null: false

      t.timestamps
    end

    add_index :appointments, [:time_slot_id, :patient_id], unique: true, name: "index_appointments_on_slot_and_patient"
    add_index :appointments, [:patient_id, :status], name: "index_appointments_on_patient_and_status"
    add_index :appointments, :booking_number, unique: true
  end
end
