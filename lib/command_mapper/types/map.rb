require 'command_mapper/types/type'

module CommandMapper
  module Types
    class Map < Type

      # @return [Hash{Object => String}]
      attr_reader :map

      #
      # Initializes the map value type.
      #
      # @param [Hash{Object => String}] map
      #   The map of values to Strings.
      #
      def initialize(map)
        @map = map
      end

      # Maps boolean values to "yes" and "no"
      YesNo = new(true => 'yes', false => 'no')

      # Maps boolean values to "enabled" and "disabled"
      EnabledDisabled = new(true => 'enabled', false => 'disabled')

      #
      # @param [Object] value
      #
      # @return [String]
      #
      def format(value)
        super(@map.fetch(value,value))
      end

    end
  end
end
