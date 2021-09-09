module CommandMapper
  module Formats
    class Map

      # @return [Hash{Object => String}]
      attr_reader :map

      def initialize(map={})
        @map = map
      end

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
