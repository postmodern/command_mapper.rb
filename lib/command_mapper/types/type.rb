module CommandMapper
  module Types
    #
    # The base type for all command-line argument types.
    #
    class Type

      #
      # The default `validate` method for all types.
      #
      # @param [Object]
      #
      # @return [true, (false, String)]
      #
      def validate(value)
        true
      end

      #
      # The default `format` method for all types.
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

    require 'command_mapper/types/str'

    #
    # Converts a value into a {Type} object.
    #
    # @param [Type, Hash, nil] value
    #
    # @return [Type]
    #
    # @raise [ArgumentError]
    #
    def self.Type(value)
      case value
      when Type      then value
      when Hash      then Str.new(**value)
      when nil       then nil
      else
        raise(ArgumentError,"value must be a #{Type}, Hash, or nil: #{value.inspect}")
      end
    end

  end
end
