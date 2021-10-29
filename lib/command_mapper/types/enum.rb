require 'command_mapper/types/map'

module CommandMapper
  module Types
    class Enum < Map

      # @return [Array<Object>]
      attr_reader :values

      #
      # Initializes the enum type.
      #
      # @param [Array<Object>] values
      #   The values of the enum type.
      #
      def initialize(values)
        @values = values

        super(Hash[values.map { |value| [value, value.to_s] }])
      end

      #
      # Creates a new enum.
      #
      # @param [Array<Object>] values
      #
      # @return [Enum]
      #
      def self.[](*values)
        new(values)
      end

    end
  end
end
