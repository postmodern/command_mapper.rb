require 'command_mapper/types/list'
require 'command_mapper/types/key_value'

module CommandMapper
  module Types
    #
    # Represents a list of `key=value` pairs.
    #
    class KeyValueList < List

      #
      # Initializes the key-value list.
      #
      # @param [String] separator
      #   The list separator character (ex: `,`).
      #
      # @param [String] key_value_separator
      #   The key-value separator (ex: `=`).
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {KeyValue#initialize}.
      #
      def initialize(separator: ',', key_value_separator: '=', **kwargs)
        super(separator: separator)

        @key_value = KeyValue.new(separator: key_value_separator, **kwargs)
      end

      #
      # Formats the value.
      #
      # @param [Hash, Array(key, value)] value
      #   The list of key-value pairs.
      #
      # @return [String]
      #   The formatted key-value list.
      #
      def format(value)
        super(Array(value).map(&@key_value))
      end

    end
  end
end
