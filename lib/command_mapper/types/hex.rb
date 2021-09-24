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
      # Formats the value.
      #
      # @param [#to_i] value
      #
      # @return [String]
      #
      def format(value)
        value = value.to_i

        if leading_zero? then "0x%x" % value
        else                  "%x" % value
        end
      end

    end
  end
end
