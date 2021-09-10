module CommandMapper
  class ArgumentValue

    # The argument value's optional format.
    #
    # @return [#call, nil]
    attr_reader :format

    #
    # Initializes the argument value.
    #
    # @param [#call] format
    #   The optional format for the argument value.
    #
    # @param [Boolean] required
    #   Specifies whether the argument is required or can be omitted.
    #
    # @param [Boolean] allow_empty
    #   Specifies whether the argument may accept empty values.
    #
    def initialize(format: nil, required: true, allow_empty: false)
      @format      = format
      @required    = required
      @allow_empty = allow_empty
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
    # Specifies whether the argument may accept empty values.
    #
    # @return [Boolean]
    #
    def allow_empty?
      @allow_empty
    end

    #
    # Formats the given value.
    #
    # @param [Object] value
    #
    # @return [String]
    #
    def format_value(value)
      if @format then @format.call(value)
      else            value.to_s
      end
    end

  end
end
