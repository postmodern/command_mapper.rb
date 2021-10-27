require 'command_mapper/types/value'

module CommandMapper
  module Types
    #
    # Represents a numeric value.
    #
    class Num < Value

      #
      # Validates a value.
      #
      # @param [String, Integer] value
      #
      # @return [true, (false, String)]
      #
      def validate(value)
        valid, message = super(value)

        unless valid
          return valid, message
        end

        case value
        when Integer
          return true
        else
          if value.respond_to?(:=~) && value =~ /^\d+$/
            return true
          else
            return false, "value must be numeric"
          end
        end
      end

    end
  end
end
