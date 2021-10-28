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
      #   Additional keyword arguments for {Type#initialize}.
      #
      def initialize(leading_zero: false)
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
      #
      # @return [true, (false, String)]
      #
      def validate(value)
        case value
        when String
          unless value =~ /\A(?:0x)?[A-Fa-f0-9]+\z/
            return [false, "value is not in hexadecimal format"]
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
      #
      # @return [String]
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
