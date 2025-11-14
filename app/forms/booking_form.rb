# frozen_string_literal: true

class BookingForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :time_slot_id, :integer
  attribute :patient_name, :string
  attribute :patient_phone, :string
  attribute :patient_email, :string
  attribute :notes, :string
  attribute :terms_accepted, :boolean, default: false

  validates :time_slot_id, :patient_name, :patient_phone, :patient_email, presence: true
  validates :patient_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :terms_accepted, acceptance: { accept: true }

  def time_slot
    @time_slot ||= TimeSlot.includes(:doctor, doctor: :clinic).find_by(id: time_slot_id)
  end

  def doctor
    time_slot&.doctor
  end

  def clinic
    doctor&.clinic
  end

  def to_appointment_attributes
    {
      patient_name: patient_name,
      patient_phone: patient_phone,
      patient_email: patient_email,
      notes: notes
    }
  end

  def validate_time_slot_availability
    errors.add(:time_slot_id, :blank, message: "Select a valid time slot") and return unless time_slot

    return if time_slot.bookable?

    errors.add(:base, "This time slot is no longer available")
  end

  def valid?(context = nil)
    super
    validate_time_slot_availability
    errors.empty?
  end
end
