# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { patient: 0, admin: 1 }, _suffix: true

  has_many :appointments, foreign_key: :patient_id, inverse_of: :patient, dependent: :nullify
end
