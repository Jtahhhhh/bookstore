module ServiceResponse
  def success(data = {}, message: nil, status: :ok)
    {
      status: status,
      message: message
    }.merge(data)
  end

  def error(message, status: :unprocessable_entity)
    {
      status: status,
      error: message
    }
  end

  def not_found(message)
    error(message, status: :not_found)
  end
end