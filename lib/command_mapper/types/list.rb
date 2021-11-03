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

      # The list element type.
      #
      # @return [Type]
      attr_reader :type

      #
      # Initializes the list type.
      #
      # @param [String] separator
      #   The list separator character.
      #
      # @param [Type, Hash] value
      #   The list's value type.
      #
      def initialize(separator: ',', type: Str.new, allow_empty: false)
        if type.nil?
          raise(ArgumentError,"type: keyword cannot be nil")
        end

        @separator = separator
        @type      = Types::Type(type)

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

      #
      # Validates the value.
      #
      # @param [Object] value
      #
      # @return [true, (false, String)]
      #
      def validate(value)
        values = Array(value)

        if values.empty?
          unless allow_empty?
            return [false, "cannot be empty"]
          end
        end

        values.each do |element|
          valid, message = @type.validate(element)

          unless valid
            return [false, "element #{message}"]
          end
        end

        return true
      end

      #
      # Formats the value into a list.
      #
      # @param [Object] value
      #
      # @return [String]
      #
      def format(value)
        Array(value).map(&@type.method(:format)).join(@separator)
      end

    end
  end
end
