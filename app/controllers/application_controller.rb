class ApplicationController < ActionController::API
  before_action :authenticate_request

  # Encode payload with secret (set JWT_SECRET in your environment variables)
  def encode_token(payload)
    JWT.encode(payload, ENV['JWT_SECRET'])
  end

  # Decode token from the Authorization header (expects: "Bearer <token>")
  def decode_token
    auth_header = request.headers['Authorization']
    if auth_header
      token = auth_header.split(' ').last
      begin
        JWT.decode(token, ENV['JWT_SECRET'], true, algorithms: ['HS256'])
      rescue JWT::DecodeError
        nil
      end
    end
  end

  # Authenticate the incoming request
  def authenticate_request
    decoded = decode_token
    if decoded
      # decoded is an array; payload is first element
      @current_user = decoded.first
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  # Enforce role-based access
  def require_role(role)
    unless @current_user && @current_user['role'] == role
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end
end
