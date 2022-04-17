require 'command_mapper/types/num'

module CommandMapper
  module Types
    #
    # Represents a hexadecimal value.
    #
    class Hex < Num

      #
      # Initializes the hex value.
      #
      # @param [Boolean] leading_zero
      #   Specifies whether the hex value will start with `0x` or not.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {Num#initialize}.
      #
      def initialize(leading_zero: false, **kwargs)
        super(**kwargs)

        @leading_zero = leading_zero
      end

      #
      # Indicates whether the hex value will start with `0x` or not.
      #
      # @return [Boolean]
      #
      def leading_zero?
        @leading_zero
      end

      #
      # Validates a value.
      #
      # @param [String, Integer, Object] value
      #   The given value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when String
          unless value =~ /\A(?:0x)?[A-Fa-f0-9]+\z/
            return [false, "not in hex format (#{value.inspect})"]
          end

          if @range
            unless @range.include?(value.to_i(16))
              return [false, "unacceptable value (#{value.inspect})"]
            end
          end

          return true
        else
          super(value)
        end
      end

      #
      # Formats the value.
      #
      # @param [#to_i] value
      #   The given numeric value.
      #
      # @return [String]
      #   The formatted numeric value.
      #
      def format(value)
        case value
        when String
          if leading_zero? && !value.start_with?('0x')
            value = "0x#{value}"
          elsif (!leading_zero? && value.start_with?('0x'))
            value = value[2..]
          end

          value
        else
          value = value.to_i

          if leading_zero?
            "0x%x" % value
          else
            "%x" % value
          end
        end
      end

    end
  end
end
