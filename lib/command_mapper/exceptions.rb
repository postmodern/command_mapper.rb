module CommandMapper
  #
  # Commaon base class for all {CommandMapper} exceptions.
  #
  class Error < RuntimeError
  end

  #
  # Represents a argument or option value validation error.
  #
  class ValidationError < Error
  end

  #
  # Indicates that a required argument was not set.
  #
  class ArgumentRequired < Error
  end
end
