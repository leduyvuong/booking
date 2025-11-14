# frozen_string_literal: true

class Appointment < ApplicationRecord
  MAX_BOOKING_RETRIES = 3

  belongs_to :time_slot, counter_cache: :booked_count
  belongs_to :patient, class_name: "User"

  enum status: { pending: 0, confirmed: 1, cancelled: 2 }

  before_validation :assign_booking_number, on: :create
  after_commit :sync_time_slot_booked_count, on: %i[create update destroy]

  validates :patient_name, :patient_phone, :patient_email, presence: true
  validates :patient_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :time_slot, presence: true
  validates :patient, presence: true
  validate :time_slot_available, on: :create

  scope :by_status, ->(status) { where(status: status) }

  def self.book!(time_slot:, patient:, attributes: {}, retries: MAX_BOOKING_RETRIES)
    attempts = 0

    begin
      transaction do
        slot_id = time_slot.is_a?(TimeSlot) ? time_slot.id : time_slot
        slot = TimeSlot.lock.where(id: slot_id).first!
        unless slot.bookable?
          slot.errors.add(:base, "is not bookable")
          raise ActiveRecord::RecordInvalid.new(slot)
        end

        appointment = slot.appointments.new(attributes)
        appointment.patient = patient
        appointment.status ||= :pending
        appointment.save!
        return appointment
      end
    rescue ActiveRecord::Deadlocked, ActiveRecord::LockWaitTimeout => e
      attempts += 1
      retry if attempts < retries
      raise e
    end
  end

  private

  def assign_booking_number
    self.booking_number ||= loop do
      token = "BKG-" + SecureRandom.alphanumeric(8).upcase
      break token unless self.class.exists?(booking_number: token)
    end
  end

  def time_slot_available
    return if time_slot.blank?
    errors.add(:time_slot, "is not available") unless time_slot.bookable?
  end

  def sync_time_slot_booked_count
    slot = TimeSlot.lock.where(id: time_slot_id).first
    return unless slot

    count = slot.appointments.where.not(status: :cancelled).count
    slot.update_columns(booked_count: count, updated_at: Time.current)
  end
end
