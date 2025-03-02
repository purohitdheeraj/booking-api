class OrganizersController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]

  def register
    organizer = EventOrganizer.new(organizer_params)
    if organizer.save
      render json: organizer, status: :created
    else
      render json: { errors: organizer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    organizer = EventOrganizer.find_by(email: params[:email])
    if organizer && organizer.authenticate(params[:password])
      token = encode_token({ id: organizer.id, role: 'organizer' })
      render json: { token: token }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  private

  def organizer_params
    params.permit(:name, :email, :password)
  end
end
