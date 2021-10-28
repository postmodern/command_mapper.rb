require 'command_mapper/types/type'
require 'command_mapper/types/str'

module CommandMapper
  module Types
    #
    # Represents a list type.
    #
    class List < Type

      # The seperator character.
      #
      # @return [String]
      attr_reader :separator

      # The value type.
      #
      # @return [Type]
      attr_reader :value

      #
      # Initializes the list type.
      #
      # @param [String] separator
      #   The list separator character.
      #
      # @param [Type, Hash] value
      #   The list's value type.
      #
      def initialize(separator: ',', value: Str.new)
        if value.nil?
          raise(ArgumentError,"value: keyword cannot be nil")
        end

        @separator = separator
        @value     = Types::Type(value)
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
