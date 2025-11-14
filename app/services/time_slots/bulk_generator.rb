# frozen_string_literal: true

module TimeSlots
  class BulkGenerator
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    SlotCandidate = Struct.new(
      :date,
      :start_time,
      :end_time,
      :max_patients,
      :status,
      :duplicate,
      keyword_init: true
    )

    attr_accessor :doctor_id, :start_date, :end_date, :start_time, :end_time, :duration_minutes, :max_patients, :status

    validates :doctor_id, :start_date, :end_date, :start_time, :end_time, :duration_minutes, :max_patients, presence: true
    validates :duration_minutes, inclusion: { in: [30, 60] }
    validates :max_patients, numericality: { greater_than: 0 }
    validates :status, inclusion: { in: TimeSlot.statuses.keys }
    validate :chronological_dates
    validate :chronological_times
    validate :doctor_exists

    before_validation :normalize_numeric_values

    def initialize(attributes = {})
      super
      @status ||= "available"
    end

    def doctor
      @doctor ||= Doctor.find_by(id: doctor_id)
    end

    def preview
      return [] unless valid?

      build_candidates
    end

    def duplicates
      preview.select(&:duplicate)
    end

    def save
      return false unless valid?

      candidates = build_candidates.reject(&:duplicate)

      ActiveRecord::Base.transaction do
        candidates.each do |candidate|
          TimeSlot.create!(
            doctor_id: doctor_id,
            date: candidate.date,
            start_time: candidate.start_time,
            end_time: candidate.end_time,
            max_patients: candidate.max_patients,
            status: candidate.status
          )
        end
      end

      @created_count = candidates.size
      true
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    def created_count
      @created_count || 0
    end

    private

    def chronological_dates
      return if start_date.blank? || end_date.blank?

      start_value = cast_date(start_date)
      end_value = cast_date(end_date)
      return if start_value && end_value && start_value <= end_value

      errors.add(:base, "Start date must be before or equal to end date")
    end

    def chronological_times
      return if start_time.blank? || end_time.blank?

      start_value = cast_time(start_time)
      end_value = cast_time(end_time)
      return if start_value && end_value && start_value < end_value

      errors.add(:base, "Start time must be before end time")
    end

    def build_candidates
      return [] if doctor.blank?

      return @candidates if defined?(@candidates)

      start_day = cast_date(start_date)
      end_day = cast_date(end_date)
      return [] if start_day.blank? || end_day.blank?

      @candidates = []
      existing_slots = existing_slots_by_date(start_day, end_day)

      (start_day..end_day).each do |day|
        day_start = cast_time_on(day, start_time)
        day_end = cast_time_on(day, end_time)
        next if day_start.blank? || day_end.blank?

        current_start = day_start

        while current_start < day_end
          current_end = current_start + duration_minutes.to_i.minutes
          break if current_end > day_end

          duplicate = conflict_with_existing?(existing_slots[day] || [], current_start, current_end)

          @candidates << SlotCandidate.new(
            date: day,
            start_time: current_start,
            end_time: current_end,
            max_patients: max_patients.to_i,
            status: status,
            duplicate: duplicate
          )

          current_start = current_end
        end
      end

      @candidates
    end

    def normalize_numeric_values
      self.duration_minutes = duration_minutes.to_i if duration_minutes.present?
      self.max_patients = max_patients.to_i if max_patients.present?
    end

    def existing_slots_by_date(start_day, end_day)
      TimeSlot.where(doctor_id: doctor_id, date: start_day..end_day).includes(:doctor).group_by(&:date)
    end

    def conflict_with_existing?(slots, candidate_start, candidate_end)
      candidate_range = (candidate_start.seconds_since_midnight)...(candidate_end.seconds_since_midnight)

      slots.any? do |slot|
        slot_start = slot.start_time.seconds_since_midnight
        slot_end = slot.end_time.seconds_since_midnight
        slot_range = slot_start...slot_end

        ranges_overlap?(candidate_range, slot_range)
      end
    end

    def ranges_overlap?(range_a, range_b)
      range_a.begin < range_b.end && range_b.begin < range_a.end
    end

    def cast_date(value)
      case value
      when Date
        value
      when String
        Date.parse(value)
      else
        nil
      end
    rescue ArgumentError
      errors.add(:base, "Invalid date provided")
      nil
    end

    def cast_time(value)
      case value
      when Time
        value
      when String
        Time.zone.parse(value)
      else
        nil
      end
    rescue ArgumentError
      errors.add(:base, "Invalid time provided")
      nil
    end

    def cast_time_on(date, time_value)
      parsed_time = cast_time(time_value)
      return if parsed_time.blank?

      Time.zone.local(date.year, date.month, date.day, parsed_time.hour, parsed_time.min)
    end

    def doctor_exists
      return if doctor_id.blank?

      errors.add(:doctor_id, "must reference an existing doctor") if doctor.nil?
    end
  end
end
