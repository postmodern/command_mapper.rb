require 'command_mapper/types/type'

module CommandMapper
  module Types
    #
    # Represents a decimal value (ex: `1.5`).
    #
    # @since 0.3.0
    #
    class Dec < Type

      # The optional range of acceptable decimal numbers.
      #
      # @return [Range<Float,Float>, nil]
      #
      # @api semipublic
      attr_reader :range

      #
      # Initializes the decimal type.
      #
      # @param [Range<Float,Float>] range
      #   Specifies the range of acceptable numbers.
      #
      def initialize(range: nil)
        @range = range
      end

      #
      # Validates a value.
      #
      # @param [String, Numeric] value
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
        when Float
          # no-op
        when String
          unless value =~ /\A\d+(?:\.\d+)?\z/
            return [false, "contains non-decimal characters (#{value.inspect})"]
          end
        else
          unless value.respond_to?(:to_f)
            return [false, "cannot be converted into a Float (#{value.inspect})"]
          end
        end

        if @range
          unless @range.include?(value.to_f)
            return [false, "(#{value.inspect}) not within the range of acceptable values (#{range.inspect})"]
          end
        end

        return true
      end

      #
      # Formats a decimal value.
      #
      # @param [String, Float, #to_f] value
      #   The given value to format.
      #
      # @return [String]
      #   The formatted decimal value.
      #
      # @api semipublic
      #
      def format(value)
        case value
        when Float, String then value.to_s
        else                    value.to_f.to_s
        end
      end

    end
  end
end
