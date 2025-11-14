# frozen_string_literal: true

class Doctor < ApplicationRecord
  belongs_to :clinic
  has_many :time_slots, dependent: :destroy
  has_many :appointments, through: :time_slots

  validates :name, :specialty, presence: true
end
