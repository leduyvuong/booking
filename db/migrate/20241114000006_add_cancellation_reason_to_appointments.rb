class AddCancellationReasonToAppointments < ActiveRecord::Migration[7.1]
  def change
    add_column :appointments, :cancellation_reason, :text
  end
end
