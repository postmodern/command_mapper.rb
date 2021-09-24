require 'command_mapper/types/value'

module CommandMapper
  module Types
    #
    # Represents a list type.
    #
    class List < Value

      # The seperator character.
      #
      # @return [String]
      attr_reader :separator

      # The value type.
      #
      # @return [Value]
      attr_reader :value

      #
      # Initializes the list type.
      #
      # @param [String] separator
      #   The list separator character.
      #
      # @param [Value, Hash, :required, :optional] value
      #   The list's value type.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {Value#initialize}.
      #
      def initialize(separator: ',', value: :required, **kwargs)
        super(**kwargs)

        if value.nil?
          raise(ArgumentError,"value: keyword cannot be nil")
        end

        @separator = separator
        @value     = Types::Value(value)
      end

      #
      # Formats the value into a list.
      #
      # @param [Object] value
      #
      # @return [String]
      #
      def format(value)
        Array(value).map(&@value.method(:format)).join(@separator)
      end

    end
  end
end
