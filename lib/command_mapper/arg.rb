require 'command_mapper/types/value'

module CommandMapper
  #
  # The base class for both {Option options} and {Argument arguments}.
  #
  class Arg
    # The argument's value type.
    #
    # @return [Value, nil]
    attr_reader :value

    #
    # Initializes the argument.
    #
    # @param [Value, Hash, :required, :optional, nil] value
    #
    # @param [Boolean] repeats
    #
    def initialize(value: nil, repeats: false)
      @value   = Types::Value(value)
      @repeats = repeats
    end

    #
    # Indicates whether the arg can be repeated multiple times or not.
    #
    # @return [Boolean]
    #
    def repeats?
      @repeats
    end

    #
    # Validates whether a given value is compatible with the arg.
    #
    # @param [Object] value
    #
    # @return [true, (false, String)]
    #   Returns true if the value is valid, or `false` and a validation error
    #   message if the value is not compatible.
    #
    def validate(value)
      if repeats?
        values = Array(value)

        if @value.required?
          # argument requires atleast one value
          if values.empty?
            return [false, "requires at least one value"]
          end
        end

        # validate each element in the value
        values.each do |element|
          valid, message = @value.validate(element)

          unless valid
            return valid, message
          end
        end

        return true
      else
        return @value.validate(value)
      end
    end

  end
end
