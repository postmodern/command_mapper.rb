require_relative 'exceptions'
require_relative 'option_value'

module CommandMapper
  #
  # Represents an option for a command.
  #
  class Option

    # The option's flag (ex: `-o` or `--output`).
    #
    # @return [String]
    attr_reader :flag

    # The option's name.
    #
    # @return [Symbol]
    attr_reader :name

    # Describes the option's value.
    #
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
    # @param [Boolean] equals
    #   Specifies whether the option's flag and value should be separated with a
    #   `=` character.
    #
    # @param [Boolean] value_in_flag
    #   Specifies that the value should be appended to the option's flag
    #   (ex: `-Fvalue`).
    #
    # @api private
    #
    def initialize(flag, name: nil, value: nil, repeats: false,
                         # formatting options
                         equals:        nil,
                         value_in_flag: nil)
      @flag    = flag
      @name    = name || self.class.infer_name_from_flag(flag)
      @value   = case value
                 when Hash then OptionValue.new(**value)
                 when true then OptionValue.new
                 end
      @repeats = repeats

      # formatting options
      @equals        = equals
      @value_in_flag = value_in_flag
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
    # @api private
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
    # Determines whether the option can be given multiple times.
    #
    # @return [Boolean]
    #
    def repeats?
      @repeats
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
    # Indicates whether the value will be appended to the option's flag.
    #
    # @return [Boolean]
    #
    # @since 0.2.0
    #
    def value_in_flag?
      @value_in_flag
    end

    #
    # Validates whether the given value is compatible with the option.
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
      if accepts_value?
        if repeats?
          validate_repeating(value)
        else
          @value.validate(value)
        end
      else
        validate_does_not_accept_value(value)
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
    # @api semipublic
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
    # Validates a value when the option can be repeated.
    #
    # @param [Array<Object>, Object] value
    #   The given value to validate.
    #
    # @return [true, (false, String)]
    #   Returns true if the value is valid, or `false` and a validation error
    #   message if the value is not compatible.
    #
    def validate_repeating(value)
      values = case value
               when Array then value
               else            [value]
               end

      if @value.required?
        # option requires atleast one value
        if values.empty?
          return [false, "requires at least one value"]
        end
      end

      values.each do |element|
        valid, message = @value.validate(element)

        unless valid
          return [false, message]
        end
      end

      return true
    end

    #
    # Validates a value when the option does not accept a value.
    #
    # @param [Array<Object>, Object] value
    #   The given value to validate.
    #
    # @return [true, (false, String)]
    #   Returns true if the value is valid, or `false` and a validation error
    #   message if the value is not compatible.
    #
    def validate_does_not_accept_value(value)
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
      case value
      when true
        argv << @flag
      when Integer
        if repeats?
          value.times { argv << @flag }
        end
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
    # @raise [VAlidationError]
    #   The formatted value starts with a `-` character.
    #
    def emit_option_flag_and_value(argv,value)
      if !@value.required? && value == true
        argv << @flag
      else
        string = @value.format(value)

        if equals?
          argv << "#{@flag}=#{string}"
        elsif value_in_flag?
          argv << "#{@flag}#{string}"
        else
          if string.start_with?('-')
            raise(ValidationError,"option #{@name} formatted value (#{string.inspect}) cannot start with a '-'")
          end

          argv << @flag << string
        end
      end
    end
  end

end
