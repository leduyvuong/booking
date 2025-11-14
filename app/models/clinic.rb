# frozen_string_literal: true

class Clinic < ApplicationRecord
  has_many :doctors, dependent: :destroy
  has_many :time_slots, through: :doctors
  has_many :appointments, through: :time_slots

  validates :name, :address, :phone, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
