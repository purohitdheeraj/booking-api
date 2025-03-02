class BookingsController < ApplicationController
  before_action do
    require_role('customer')
  end

  def create
    customer = Customer.find(@current_user['id'])
    event = Event.find_by(id: params[:event_id])
    ticket = Ticket.find_by(id: params[:ticket_id], event_id: params[:event_id])
    
    if event.nil? || ticket.nil?
      render json: { error: 'Event or Ticket not found' }, status: :not_found and return
    end

    quantity = params[:quantity].to_i
    if ticket.available_quantity < quantity
      render json: { error: 'Not enough tickets available' }, status: :bad_request and return
    end

    # Deduct the booked quantity from available_quantity
    ticket.update(available_quantity: ticket.available_quantity - quantity)

    booking = Booking.create(
      customer: customer,
      event: event,
      ticket: ticket,
      quantity: quantity,
      booking_date: Time.now
    )

    # Enqueue a Sidekiq job to simulate sending a booking confirmation email
    SendBookingEmailJob.perform_async(customer.email, booking.id)
    
    render json: booking, status: :created
  end
end
