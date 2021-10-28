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
      #
      # @return [true, (false, String)]
      #
      def validate(value)
        case value
        when Integer
          return true
        when String
          unless value =~ /\A\d+\z/
            return [false, "value contains non-numeric characters"]
          end
        else
          unless value.respond_to?(:to_i)
            return [false, "value cannot be converted into an Integer"]
          end
        end

        return true
      end

    end
  end
end
