module CommandMapper
  class Exception < RuntimeError
  end

  #
  # Represents a argument or option value validation error.
  #
  class ValidationError < Exception
  end

  class ArgumentRequired < Exception
  end
end
