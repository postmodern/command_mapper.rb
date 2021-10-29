module CommandMapper
  module Types
    #
    # The base type for all command-line argument types.
    #
    # ## Custom Types
    #
    # Custom types can be defined by extending the {Type} class.
    # 
    #     class PortRange < CommandMapper::Types::Type
    #     
    #       def validate(value)
    #         case value
    #         when Integer
    #           true
    #         when Range
    #           if value.begin.kind_of?(Integer)
    #             true
    #           else
    #             [false, "port range can only contain Integers"]
    #           end
    #         else
    #           [false, "port range must be an Integer or a Range of Integers"]
    #         end
    #       end
    #     
    #       def format(value)
    #         case value
    #         when Integer
    #           "#{value}"
    #         when Range
    #           "#{value.begin}-#{value.end}"
    #         end
    #       end
    #     
    #     end
    #
    #
    # The custom type can define the following methods:
    #
    # * `#initialize` - accepts additional configuration options.
    # * `#validate` - accepts a value object and returns `true` (indicating the
    #   value is valid) or `[false, message]` (indicating the value is invalid).
    # * `#format` - accepts a validated value and returns a formatted String.
    #
    # Once defined, custom {Type} classes can be used with `option` or
    # `argument` and passed in via the `type:` keyword argument.
    #
    #     option "--ports", value: {required: true, type: PortRange.new}
    #
    #     argument :ports, required: true, type: PortRange.new
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
