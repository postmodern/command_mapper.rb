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
      # @param [Boolean] allow_empty
      #   Specifies whether the argument may accept empty values.
      #
      def initialize(required: true, allow_empty: false, allow_blank: false)
        @required = required

        @allow_empty = allow_empty
        @allow_blank = allow_blank
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
      # Specifies whether the option's value may accept empty values.
      #
      # @return [Boolean]
      #
      def allow_empty?
        @allow_empty
      end

      #
      # Specifies whether the option's value may accept blank values.
      #
      # @return [Boolean]
      #
      def allow_blank?
        @allow_blank
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
      #   * If an empty value is given and empty values are not allowed, then
      #     `false` will be returned.
      #   * If an empty value is given and blank values are not allowed, then
      #     `false` will be returned.
      #
      def validate(value)
        if value.nil?
          if required?
            return [false, "does not allow a nil value"]
          end
        elsif value.respond_to?(:empty?) && value.empty?
          unless allow_empty?
            return [false, "does not allow an empty value"]
          end
        elsif value.respond_to?(:=~) && value =~ /\A\s+\z/
          unless allow_blank?
            return [false, "does not allow a blank value"]
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
      when Hash      then Value.new(**value)
      when :required then Value.new(required: true)
      when :optional then Value.new(required: false)
      when nil       then nil
      else
        raise(ArgumentError,"value must be a #{Value}, Hash, :required, :optional, or nil: #{value.inspect}")
      end
    end

  end
end
