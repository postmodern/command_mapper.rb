require 'command_mapper/exceptions'
require 'command_mapper/arg'

module CommandMapper
  #
  # Represents an additional argument of a command.
  #
  class Argument < Arg

    # The argument name.
    #
    # @return [Symbol]
    attr_reader :name

    #
    # Initializes the argument.
    #
    # @param [Symbol] name
    #   The argument's name.
    #
    # @param [Types::Type, Hash, :required, :optional] value
    #   The value type of the argument.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments for {Arg#initialize}.
    #
    # @option kwargs [Boolean] :repeats
    #   Specifies whether the argument can be given multiple times.
    #
    # @raise [ArgumentError]
    #   The given `value:` must not be `false` or `nil`.
    #
    def initialize(name, value: :required, **kwargs)
      @name = name

      unless value
        raise(ArgumentError,"value: must not be false or nil")
      end

      super(value: value, **kwargs)
    end

    #
    # Converts the given value into the command-line arguments for the
    # argument's flag and value.
    #
    # @param [Array] argv
    #   The argv array.
    #
    # @param [Object] value
    #   The value for the argument.
    #
    # @return [Array<String>]
    #   The command-line arguments.
    #
    # @raise [ArgumentError]
    #   The given value was incompatible with the argument.
    #
    def argv(argv=[],value)
      valid, message = validate(value)

      unless valid
        raise(ValidationError,"argument #{@name} was given an invalid value (#{value.inspect}): #{message}")
      end

      if repeats?
        values = Array(value)

        values.each do |element|
          emit_arg_value(argv,element)
        end
      else
        emit_arg_value(argv,value)
      end

      return argv
    end

    private

    #
    # Emits a single command-line arg value.
    #
    # @param [Array<String>] argv
    #   The argv array to append to.
    #
    # @param [Object] value
    #   The value for the argument.
    #
    def emit_arg_value(argv,value)
      # explicitly ignore nil values
      unless value.nil?
        argv << @value.format(value)
      end
    end

  end
end
