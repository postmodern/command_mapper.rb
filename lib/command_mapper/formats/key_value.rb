module CommandMapper
  module Formats
    class KeyValue

      def initialize(separator)
        @separator = separator
      end

      def call(value)
        case value
        when Array
          key, value = value

          "#{key}#{@separator}#{value}"
        else
          value.to_s
        end
      end

    end
  end
end
