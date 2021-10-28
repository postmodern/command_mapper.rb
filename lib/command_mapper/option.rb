require 'command_mapper/exceptions'
require 'command_mapper/option_value'

module CommandMapper
  #
  # Represents an option for a command.
  #
  class Option

    # @return [String]
    attr_reader :flag

    # @return [Symbol]
    attr_reader :name

    # @return [OptionValue, nil]
    attr_reader :value

    #
    # Initializes the option.
    #
    # @param [String] flag
    #   The option's flag (ex: `-o` or `--output`).
    #
    # @param [Symbol, nil] name
    #   The option's name.
    #
    # @param [Boolean] equals
    #   Specifies whether the option's flag and value should be separated with a
    #   `=` character.
    #
    # @param [Hash, nil] value
    #   The option's value.
    #
    # @option value [Boolean] :required
    #   Specifies whether the option requires a value or not.
    #
    # @option value [Types:Type, Hash, nil] :type
    #   The explicit type for the option's value.
    #
    # @param [Boolean] repeats
    #   Specifies whether the option can be given multiple times.
    #
    def initialize(flag, name: nil, equals: nil, value: nil, repeats: false)
      @flag    = flag
      @name    = name || self.class.infer_name_from_flag(flag)
      @equals  = equals
      @value   = case value
                 when Hash then OptionValue.new(**value)
                 when true then OptionValue.new
                 end
      @repeats = repeats
    end

    #
    # Infers a method name from the given option flag.
    #
    # @param [String] flag
    #   The given long or short option flag.
    #
    # @return [Symbol]
    #   The inferred method method name.
    #
    # @raise [ArgumentError]
    #   Could not infer the name from the given option flag or was not given a
    #   valid option flag.
    #
    def self.infer_name_from_flag(flag)
      if flag.start_with?('--')
        name = flag[2..-1]
      elsif flag.start_with?('-')
        name = flag[1..-1]

        if name.length < 2
          raise(ArgumentError,"cannot infer a name from short option flag: #{flag.inspect}")
        end
      else
        raise(ArgumentError,"not an option flag: #{flag}")
      end

      name.downcase.gsub(/[_-]+/,'_').to_sym
    end

    #
    # Indicates whether the option accepts a value.
    #
    # @return [Boolean]
    #
    def accepts_value?
      !@value.nil?
    end

    #
    # Indicates whether the option flag and value should be separated with a
    # `=` character.
    #
    # @return [Boolean]
    #
    def equals?
      @equals
    end

    #
    # Determines whether the option can be given multiple times.
    #
    # @return [Boolean]
    #
    def repeats?
      @repeats
    end

    #
    # Validates whether the given value is compatible with the option.
    #
    # @param [Object] value
    #
    # @return [true, (false, String)]
    #   Returns true if the value is valid, or `false` and a validation error
    #   message if the value is not compatible.
    #
    def validate(value)
      if accepts_value?
        @value.validate(value)
      else
        case value
        when true, false, nil
          return true
        when Integer
          if repeats?
            return true
          else
            return [false, "only repeating options may accept Integers"]
          end
        else
          return [false, "only accepts true, false, or nil"]
        end
      end
    end

    #
    # Converts the given value into the command-line arguments for the option's
    # flag and value.
    #
    # @param [Array] argv
    #   The argv array.
    #
    # @param [Object] value
    #   The value given to the option.
    #
    # @return [Array<String>]
    #
    # @raise [ArgumentError]
    #   The given value was incompatible with the option.
    #
    def argv(argv=[],value)
      valid, message = validate(value)

      unless valid
        raise(ValidationError,"option #{@name} was given an invalid value (#{value.inspect}): #{message}")
      end

      if accepts_value?
        if repeats?
          values = Array(value)

          values.each do |element|
            emit_option_flag_and_value(argv,element)
          end
        else
          emit_option_flag_and_value(argv,value)
        end
      else
        emit_option_flag_only(argv,value)
      end

      return argv
    end

    private

    #
    # Emits the option's flag.
    #
    # @param [Array<String>] argv
    #   The argv array to append to.
    #
    # @param [true, false, nil] value
    #   Indicates whether to emit the option's flag or not.
    #
    def emit_option_flag_only(argv,value)
      if value == true
        argv << @flag
      elsif repeats? && value.kind_of?(Integer)
        value.times { argv << @flag }
      end
    end

    #
    # Emits the option's flag and value.
    #
    # @param [Array<String>] argv
    #   The argv array to append to.
    #
    # @param [Object] value
    #   The value for the option.
    #
    def emit_option_flag_and_value(argv,value)
      # explicitly ignore nil values
      unless value.nil?
        value = @value.format(value)

        if equals?
          argv << "#{@flag}=#{value}"
        else
          argv << @flag << value
        end
      end
    end

  end
end
