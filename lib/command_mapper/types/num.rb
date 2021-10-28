require 'command_mapper/types/value'

module CommandMapper
  module Types
    #
    # Represents a numeric value.
    #
    class Num < Value

      #
      # Initializes the num type.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {Value#initialize}.
      #
      def initialize(allow_blank: false, **kwargs)
        super(allow_blank: allow_blank, **kwargs)
      end

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
