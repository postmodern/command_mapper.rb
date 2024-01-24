require_relative 'type'

module CommandMapper
  module Types
    #
    # Represents a mapping of Ruby values to other String values.
    #
    class Map < Type

      # The map of values to Strings.
      #
      # @return [Hash{Object => String}]
      #
      # @api semipublic
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

      #
      # Creates a new map.
      #
      # @param [Hash{Object => String}] map
      #   The map of values to Strings.
      #
      # @return [Map]
      #
      def self.[](map)
        new(map)
      end

      # Maps boolean values to "yes" and "no"
      YesNo = new(true => 'yes', false => 'no')

      # Maps boolean values to "enabled" and "disabled"
      EnabledDisabled = new(true => 'enabled', false => 'disabled')

      #
      # Validates a value.
      #
      # @param [Object] value
      #   The given value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the value is valid, or `false` and a validation error
      #   message if the value is not compatible.
      #
      # @api semipublic
      #
      def validate(value)
        unless (@map.has_key?(value) || @map.has_value?(value))
          return [false, "unknown value (#{value.inspect}) must be #{@map.keys.map(&:inspect).join(', ')}, or #{@map.values.map(&:inspect).join(', ')}"]
        end

        return true
      end

      #
      # Maps a value.
      #
      # @param [Object] value
      #   The given value.
      #
      # @return [String]
      #   The mapped value.
      #
      # @raise [KeyError]
      #   The given value is not a key or value in the map.
      #
      # @api semipublic
      #
      def format(value)
        if @map.has_key?(value)
          super(@map[value])
        elsif @map.has_value?(value)
          super(value)
        else
          raise(KeyError,"value (#{value.inspect}) is not a key or value in the map: #{@map.inspect}")
        end
      end

    end
  end
end
