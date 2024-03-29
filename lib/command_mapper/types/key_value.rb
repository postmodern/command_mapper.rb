require_relative 'type'
require_relative 'str'

module CommandMapper
  module Types
    #
    # Represents a key-value type.
    #
    class KeyValue < Type

      # The separator String between the key and value.
      #
      # @return [String]
      #
      # @api semipublic
      attr_reader :separator

      # The key's type.
      #
      # @return [Type]
      #
      # @api semipublic
      attr_reader :key

      # The value's type.
      #
      # @return [Type]
      #
      # @api semipublic
      attr_reader :value

      #
      # Initializes the key-value value type.
      #
      # @param [String] separator
      #   The key-value separator.
      #
      # @param [Type, Hash] key
      #   The key's value type.
      #
      # @param [Type, Hash] value
      #   The value's value type.
      #
      def initialize(separator: '=', key: Str.new, value: Str.new)
        @separator = separator

        if key.nil?
          raise(ArgumentError,"key: keyword cannot be nil")
        end

        if value.nil?
          raise(ArgumentError,"value: keyword cannot be nil")
        end

        @key   = Types::Type(key)
        @value = Types::Type(value)
      end

      #
      # Valides the given value.
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
        case value
        when Hash
          if value.length < 1
            return [false, "cannot be empty"]
          end

          if value.length > 1
            return [false, "cannot contain multiple key:value pairs (#{value.inspect})"]
          end

          key, value = value.first
        when Array
          if value.length < 2
            return [false, "must contain two elements (#{value.inspect})"]
          end

          if value.length > 2
            return [false, "cannot contain more than two elements (#{value.inspect})"]
          end

          key, value = value
        else
          return [false, "must be a Hash or an Array (#{value.inspect})"]
        end

        valid, message = @key.validate(key)

        unless valid
          return [false, "key #{message}"]
        end

        valid, message = @value.validate(value)

        unless valid
          return [false, "value #{message}"]
        end

        return true
      end

      #
      # Formats a value into a key-value pair.
      #
      # @param [Hash, Array, #to_s] value
      #   The given value to format.
      #
      # @return [String]
      #   The formatted key-value pair.
      #
      # @api semipublic
      #
      def format(value)
        case value
        when Hash, Array
          case value
          when Hash
            key, value = value.first
          when Array
            key, value = value
          end

          "#{@key.format(key)}#{@separator}#{@value.format(value)}"
        else
          super(value)
        end
      end

    end
  end
end
