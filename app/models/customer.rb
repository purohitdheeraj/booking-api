class Customer < ApplicationRecord
  has_secure_password
  has_many :bookings, dependent: :destroy
end