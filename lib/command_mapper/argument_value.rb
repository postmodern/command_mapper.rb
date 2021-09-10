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

    def format_value(value)
      if @format then @format.call(value)
      else            value.to_s
      end
    end

  end
end
