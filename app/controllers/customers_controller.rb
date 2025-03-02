class CustomersController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]

  def register
    customer = Customer.new(customer_params)
    if customer.save
      render json: customer, status: :created
    else
      render json: { errors: customer.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    customer = Customer.find_by(email: params[:email])
    if customer && customer.authenticate(params[:password])
      token = encode_token({ id: customer.id, role: 'customer' })
      render json: { token: token }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  private

  def customer_params
    params.permit(:name, :email, :password)
  end
end
