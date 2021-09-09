require 'command_mapper/option_value'

module CommandMapper
  class Option

    # @return [String]
    attr_reader :flag

    # @return [Symbol]
    attr_reader :name

    # @return [OptionValue, nil]
    attr_reader :value

    def initialize(flag, name: nil, equals: nil, repeats: false, value: nil, &block)
      @flag    = flag
      @name    = self.class.infer_name_from_flag(flag)
      @equals  = equals
      @repeats = repeats

      @value = case value
               when true then OptionValue.new(required: true)
               when Hash then OptionValue.new(**value)
               when nil  then nil
               else
                 raise(ArgumentError,"value: keyword must be a Hash or true: #{value.inspect}")
               end
    end

    def has_value?
      !@value.nil?
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

    def equals?
      @equals
    end

    def repeats?
      @repeats
    end

    def value?
      !@value.nil?
    end

    def argv(value)
    end

  end
end
