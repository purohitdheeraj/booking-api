class EventsController < ApplicationController
  # Only organizers can create, update, destroy events and create tickets
  skip_before_action :authenticate_request, only: [:index, :tickets]
  
  before_action only: [:create, :update, :destroy, :create_ticket] do
    require_role('organizer')
  end

  def index
    events = Event.all
    render json: events
  end

  def create
    organizer = EventOrganizer.find(@current_user['id'])
    event = organizer.events.build(event_params)
    if event.save
      render json: event, status: :created
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find_by(id: params[:id])
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found and return
    end

    if event.event_organizer_id != @current_user['id']
      render json: { error: 'Forbidden: insufficient rights' }, status: :forbidden and return
    end

    if event.update(event_params)
      # Notify all customers who booked tickets for this event
      event.bookings.includes(:customer).each do |booking|
        SendEventUpdateNotificationJob.perform_async(booking.customer.email, event.id)
      end
      render json: event
    else
      render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    event = Event.find_by(id: params[:id])
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found and return
    end

    if event.event_organizer_id != @current_user['id']
      render json: { error: 'Forbidden: insufficient rights' }, status: :forbidden and return
    end

    event.destroy
    render json: { message: 'Event deleted successfully' }
  end

  # Create a ticket for an event
  def create_ticket
    event = Event.find_by(id: params[:id])
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found and return
    end

    if event.event_organizer_id != @current_user['id']
      render json: { error: 'Forbidden: insufficient rights' }, status: :forbidden and return
    end

    ticket = event.tickets.build(ticket_params)
    if ticket.save
      render json: ticket, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # List tickets for a given event
  def tickets
    event = Event.find_by(id: params[:id])
    if event.nil?
      render json: { error: 'Event not found' }, status: :not_found
    else
      render json: event.tickets
    end
  end

  private

  def event_params
    params.permit(:title, :description, :date, :venue)
  end

  def ticket_params
    params.permit(:ticket_type, :price, :available_quantity)
  end
end
