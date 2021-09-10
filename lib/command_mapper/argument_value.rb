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
    def initialize(format: nil, required: true, &block)
      @format   = format
      @required = required

      @formatter = block
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
