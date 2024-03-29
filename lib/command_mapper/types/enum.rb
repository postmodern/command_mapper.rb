require_relative 'map'

module CommandMapper
  module Types
    #
    # Represents a mapping of Ruby values to their String equivalents.
    #
    class Enum < Map

      # The values of the enum.
      #
      # @return [Array<Object>]
      #
      # @api semipublic
      #
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
      #   List of enum values.
      #
      # @return [Enum]
      #   The newly created enum object.
      #
      def self.[](*values)
        new(values)
      end

    end
  end
end
