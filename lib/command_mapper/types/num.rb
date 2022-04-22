require 'command_mapper/types/type'

module CommandMapper
  module Types
    #
    # Represents a numeric value.
    #
    class Num < Type

      # The optional range of acceptable numbers.
      #
      # @return [Range, nil]
      #
      # @api semipublic
      attr_reader :range

      #
      # Initializes the numeric value.
      #
      # @param [Range] range
      #   Specifies the range of acceptable numbers.
      #
      def initialize(range: nil)
        @range = range
      end

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
      # @api semipublic
      #
      def validate(value)
        case value
        when Integer
          # no-op
        when String
          unless value =~ /\A\d+\z/
            return [false, "contains non-numeric characters (#{value.inspect})"]
          end
        else
          unless value.respond_to?(:to_i)
            return [false, "cannot be converted into an Integer (#{value.inspect})"]
          end
        end

        if @range
          unless @range.include?(value.to_i)
            return [false, "(#{value.inspect}) not within the range of acceptable values (#{range.inspect})"]
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
      # @api semipublic
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
