require 'command_mapper/types/list'
require 'command_mapper/types/key_value'

module CommandMapper
  module Types
    class KeyValueList < List

      def initialize(separator: ',', key_value_separator: '=', **kwargs)
        super(separator: separator)

        @key_value = KeyValue.new(separator: key_value_separator, **kwargs)
      end

      def format(value)
        super(Array(value).map(&@key_value))
      end

    end
  end
end
