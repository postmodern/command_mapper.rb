module CommandMapper
  module Formats
    class Map

      # @return [Hash{Object => String}]
      attr_reader :map

      def initialize(map={})
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
      def call(value)
        @map.fetch(value) { value.to_s }
      end

    end
  end
end
