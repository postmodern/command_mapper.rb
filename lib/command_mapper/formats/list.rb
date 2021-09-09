module CommandMapper
  module Formats
    class List

      attr_reader :separator

      def initialize(separator=',')
        @separatr = separator
      end

      def call(value)
        Array(value).join(@separator)
      end

    end
  end
end
