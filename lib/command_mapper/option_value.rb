require 'command_mapper/arg'

module CommandMapper
  #
  # Represents the value for an option.
  #
  class OptionValue < Arg

    #
    # Formats a value using the options {#type}.
    #
    # @param [Object] value
    #   The given value to format.
    #
    # @return [String]
    #   The formatted value.
    #
    def format(value)
      @type.format(value)
    end

  end
end
