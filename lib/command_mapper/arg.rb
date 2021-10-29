require 'command_mapper/types/type'
require 'command_mapper/types/str'

module CommandMapper
  #
  # The base class for both {Option options} and {Argument arguments}.
  #
  class Arg
    # The argument's arg's type.
    #
    # @return [Types::Type, nil]
    attr_reader :type

    #
    # Initializes the argument.
    #
    # @param [Boolean] required
    #   Specifies whether the argument is required or can be omitted.
    #
    # @param [Types::Type, Hash, nil] type
    #
    # @raise [ArgumentError]
    #   The `type` keyword argument was given a `nil` value.
    #
    def initialize(required: true, type: Types::Str.new)
      @required = required

      if type.nil?
        raise(ArgumentError,"type: keyword cannot be nil")
      end

      @type = Types::Type(type)
    end

    #
    # Specifies whether the argument value is required.
    #
    # @return [Boolean]
    #
    def required?
      @required
    end

    #
    # Specifies whether the argument value can be omitted.
    #
    # @return [Boolean]
    #
    def optional?
      !@required
    end

    #
    # Validates whether a given value is compatible with the arg.
    #
    # @param [Object] value
    #
    # @return [true, (false, String)]
    #   Returns true if the value is valid, or `false` and a validation error
    #   message if the value is not compatible.
    #
    def validate(value)
      if value.nil?
        if required?
          return [false, "does not allow a nil value"]
        else
          return true
        end
      end

      if @type
        return @type.validate(value)
      end

      return true
    end

  end
end
