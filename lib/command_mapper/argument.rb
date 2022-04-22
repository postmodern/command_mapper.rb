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
    # @param [Boolean] required
    #   Specifies whether the argument is required or can be omitted.
    #
    # @param [Types::Type, Hash] type
    #   The value type of the argument.
    #
    # @param [Boolean] repeats
    #   Specifies whether the argument can be given multiple times.
    #
    # @raise [ArgumentError]
    #   The given `type:` must not be `false` or `nil`.
    #
    # @api private
    #
    def initialize(name, required: true, type: Types::Str.new, repeats: false)
      super(required: required, type: type)

      @name    = name
      @repeats = repeats
    end

    #
    # Indicates whether the arg can be repeated multiple times or not.
    #
    # @return [Boolean]
    #
    def repeats?
      @repeats
    end

    #
    # Validates whether a given value is compatible with the arg.
    #
    # @param [Array<Object>, Object] value
    #   The given value to validate.
    #
    # @return [true, (false, String)]
    #   Returns true if the value is valid, or `false` and a validation error
    #   message if the value is not compatible.
    #
    # @api semipublic
    #
    def validate(value)
      if repeats?
        values = case value
                 when Array then value
                 else            [value]
                 end

        if required?
          # argument requires atleast one value
          if values.empty?
            return [false, "requires at least one value"]
          end
        end

        # validate each element in the value
        values.each do |element|
          valid, message = @type.validate(element)

          unless valid
            return [valid, message]
          end
        end

        return true
      else
        super(value)
      end
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
    # @api semipublic
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
        argv << @type.format(value)
      end
    end

  end
end
