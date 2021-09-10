require 'command_mapper/argument_value'

module CommandMapper
  class OptionValue < ArgumentValue

    def initialize(allow_empty: false, required: true, **kwargs)
      super(required: required, **kwargs)

      @allow_empty = allow_empty
    end

    #
    # Specifies whether the option's value may accept empty values.
    #
    # @return [Boolean]
    #
    def allow_empty?
      @allow_empty
    end

  end
end
