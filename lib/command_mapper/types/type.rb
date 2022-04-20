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
    # @api semipublic
    #
    class Type

      #
      # The default `validate` method for all types.
      #
      # @param [Object]
      #   The given value to format.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      def validate(value)
        true
      end

      #
      # The default `format` method for all types.
      #
      # @param [#to_s] value
      #   The given value to format.
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
    #   The type value or `Hash` of keyword arguments.
    #
    # @return [Type, Str]
    #   The type object or a new {Str} type object if a `Hash` of keyword
    #   arguments is given.
    #
    # @raise [ArgumentError]
    #   The given type value was not a {Type}, `Hash`, or `nil`,
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
