require 'command_mapper/types/type'

module CommandMapper
  module Types
    #
    # Represents a numeric value.
    #
    class Num < Type

      #
      # Validates a value.
      #
      # @param [String, Integer] value
      #   The given value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        case value
        when Integer
          return true
        when String
          unless value =~ /\A\d+\z/
            return [false, "contains non-numeric characters (#{value.inspect})"]
          end
        else
          unless value.respond_to?(:to_i)
            return [false, "cannot be converted into an Integer (#{value.inspect})"]
          end
        end

        return true
      end

      #
      # Formats a numeric value.
      #
      # @param [String, Integer, #to_i] value
      #   The given value to format.
      #
      # @return [String]
      #   The formatted numeric value.
      #
      def format(value)
        case value
        when Integer, String then value.to_s
        else                      value.to_i.to_s
        end
      end

    end
  end
end
