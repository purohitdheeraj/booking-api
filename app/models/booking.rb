class Booking < ApplicationRecord
  belongs_to :customer
  belongs_to :event
  belongs_to :ticket
end
