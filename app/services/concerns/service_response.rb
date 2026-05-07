# app/services/concerns/service_response.rb

module ServiceResponse
  def success(message, data = {})
    response(:created, message, data)
  end

  def ok(message, data = {})
    response(:ok, message, data)
  end

  def error(message, status = :unprocessable_entity)
    {
      status: status,
      error: message
    }
  end

  def not_found(message)
    error(message, :not_found)
  end

  private

  def response(status, message, data = {})
    {
      status: status,
      message: message
    }.merge(data)
  end
end