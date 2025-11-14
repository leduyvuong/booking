class CreateTimeSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :time_slots do |t|
      t.references :doctor, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.integer :max_patients, null: false, default: 1
      t.integer :booked_count, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :time_slots, [:doctor_id, :date, :status], name: "index_time_slots_on_doctor_date_status"

    add_check_constraint :time_slots, "booked_count <= max_patients", name: "booked_not_exceed_max"
    add_check_constraint :time_slots, "booked_count >= 0", name: "booked_non_negative"
  end
end
