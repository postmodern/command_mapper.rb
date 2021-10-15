module CommandMapper
  #
  # Represents a argument or option value validation error.
  #
  class ValidationError < ArgumentError
  end

  class ArgumentRequired < ValidationError
  end
end
