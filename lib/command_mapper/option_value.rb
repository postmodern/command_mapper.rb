require 'command_mapper/argument_value'

module CommandMapper
  class OptionValue < ArgumentValue

    def initialize(allow_empty: false, required: true, **kwargs)
      @allow_empty = allow_empty

      super(required: required, **kwargs)
    end

    def allow_empty?
      @allow_empty
    end

  end
end
