class SendBookingEmailJob
  include Sidekiq::Job

  def perform(email, booking_id)
    puts "Email confirmation will be sent to #{email} for booking ID #{booking_id}"
  end
end
