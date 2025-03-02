class EventOrganizer < ApplicationRecord
  has_secure_password
  has_many :events, dependent: :destroy
end