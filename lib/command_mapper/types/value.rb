module CommandMapper
  module Types
    #
    # The base value for all command-line argument or option values.
    #
    class Value

      #
      # Initializes the value.
      #
      # @param [Boolean] required
      #   Specifies whether the argument is required or can be omitted.
      #
      def initialize(required: true)
        @required = required
      end

      #
      # Specifies whether the argument value is required.
      #
      # @return [Boolean]
      #
      def required?
        @required
      end

      #
      # Specifies whether the argument value can be omitted.
      #
      # @return [Boolean]
      #
      def optional?
        !@required
      end

      #
      # Validates the given value.
      #
      # @param [Object] value
      #   The given value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the valid is considered valid, or false and a
      #   validation message if the value is not valid.
      #   * If `nil` is given and a value is required, then `false` will be
      #     returned.
      #
      def validate(value)
        if value.nil?
          if required?
            return [false, "does not allow a nil value"]
          end
        end

        return true
      end

      #
      # Validates and converts the value to a String.
      #
      # @param [#to_s] value
      #
      # @return [String]
      #   The String version of the value.
      #
      def format(value)
        value.to_s
      end

    end

    require 'command_mapper/types/str'

    #
    # Converts a value into a {Value} object.
    #
    # @param [Value, Hash, :required, :optional, nil] value
    #
    # @return [Value]
    #
    # @raise [ArgumentError]
    #
    def self.Value(value)
      case value
      when Value     then value
      when Hash      then Str.new(**value)
      when :required then Str.new(required: true)
      when :optional then Str.new(required: false)
      when nil       then nil
      else
        raise(ArgumentError,"value must be a #{Value}, Hash, :required, :optional, or nil: #{value.inspect}")
      end
    end

  end
end
