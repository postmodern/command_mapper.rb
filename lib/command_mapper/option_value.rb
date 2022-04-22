require 'command_mapper/arg'

module CommandMapper
  #
  # Represents the value for an option.
  #
  class OptionValue < Arg

    #
    # Validates whether a given value is compatible with the option {#type}.
    #
    # @param [Object] value
    #   The given value to validate.
    #
    # @return [true, (false, String)]
    #   Returns true if the value is valid, or `false` and a validation error
    #   message if the value is not compatible.
    #
    # @api semipublic
    #
    def validate(value)
      if !required? && value == true
        return true
      else
        super(value)
      end
    end

    #
    # Formats a value using the options {#type}.
    #
    # @param [Object] value
    #   The given value to format.
    #
    # @return [String]
    #   The formatted value.
    #
    # @api semipublic
    #
    def format(value)
      @type.format(value)
    end

  end
end
