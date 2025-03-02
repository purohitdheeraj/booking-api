class SendEventUpdateNotificationJob
  include Sidekiq::Job

  def perform(email, event_id)
    puts "Event update notification will be sent to #{email} for event ID #{event_id}"
  end
end
