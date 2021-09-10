require 'command_mapper/argument_value'

module CommandMapper
  class Argument < ArgumentValue

    attr_reader :name

    def initialize(name, repeats: false, **kwargs)
      @name    = name
      @repeats = repeats

      super(**kwargs)
    end

    def repeats?
      @repeats
    end

    def argv(value)
    end

  end
end
