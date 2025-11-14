# frozen_string_literal: true

class TimeSlot < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :doctor
  has_many :appointments, dependent: :destroy

  enum status: { available: 0, blocked: 1 }

  validates :date, :start_time, :end_time, :max_patients, presence: true
  validates :max_patients, numericality: { greater_than: 0 }
  validates :booked_count, numericality: { greater_than_or_equal_to: 0 }
  validates :start_time, comparison: { less_than: :end_time }
  validate :no_overlapping_slots
  validate :booked_within_capacity

  scope :ordered, -> { order(:date, :start_time) }
  scope :on_date, ->(date) { date.present? ? where(date: date) : all }

  def self.stream_name_for(doctor_id:, date:)
    "time_slots:doctor:#{doctor_id}:date:#{date}"
  end

  def available_slots
    [max_patients - booked_count.to_i, 0].max
  end

  def bookable?
    available? && available_slots.positive?
  end

  def start_at
    Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min)
  end

  def end_at
    Time.zone.local(date.year, date.month, date.day, end_time.hour, end_time.min)
  end

  def broadcast_availability(just_booked: false)
    stream_name = self.class.stream_name_for(doctor_id: doctor_id, date: date)
    broadcast_replace_to(
      stream_name,
      target: dom_id(self),
      partial: "time_slots/slot",
      locals: { time_slot: self, just_booked: just_booked }
    )
  end

  private

  def no_overlapping_slots
    return if doctor_id.blank? || date.blank? || start_time.blank? || end_time.blank?

    overlap = self.class
              .where(doctor_id: doctor_id, date: date)
              .where.not(id: id)
              .where("(start_time::time, end_time::time) OVERLAPS (?::time, ?::time)", start_time, end_time)

    errors.add(:base, "overlaps with another time slot") if overlap.exists?
  end

  def booked_within_capacity
    return if max_patients.blank?

    errors.add(:booked_count, "cannot exceed max patients") if booked_count.to_i > max_patients
  end
end
