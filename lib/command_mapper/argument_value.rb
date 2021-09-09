module CommandMapper
  class ArgumentValue

    attr_reader :format

    def initialize(format: nil, required: true, &block)
      @format   = format
      @required = required

      @formatter = block
    end

    def required?
      @required
    end

    def optional?
      !@required
    end

    def argv(value)
    end

  end
end
