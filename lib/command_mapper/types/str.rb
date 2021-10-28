require 'command_mapper/types/value'

module CommandMapper
  module Types
    class Str < Value
      #
      # Initializes the value.
      #
      # @param [Boolean] allow_empty
      #   Specifies whether the argument may accept empty values.
      #
      # @param [Boolean] allow_blank
      #   Specifies whether the argument may accept blank values.
      #
      # @param [Hash{Symbol => Object}] kwargs
      #   Additional keyword arguments for {Value#initialize}.
      #
      def initialize(allow_empty: false, allow_blank: false, **kwargs)
        super(**kwargs)

        @allow_empty = allow_empty
        @allow_blank = allow_blank
      end

      #
      # Specifies whether the option's value may accept empty values.
      #
      # @return [Boolean]
      #
      def allow_empty?
        @allow_empty
      end

      #
      # Specifies whether the option's value may accept blank values.
      #
      # @return [Boolean]
      #
      def allow_blank?
        @allow_blank
      end

      #
      # Validates the given value.
      #
      # @param [Object] value
      #   The given value to validate.
      #
      # @return [true, (false, String)]
      #   Returns true if the valid is considered valid, or false and a
      #   validation message if the value is not valid.
      #   * If `nil` is given and a value is required, then `false` will be
      #     returned.
      #   * If an empty value is given and empty values are not allowed, then
      #     `false` will be returned.
      #   * If an empty value is given and blank values are not allowed, then
      #     `false` will be returned.
      #
      def validate(value)
        valid, message = super(value)

        unless valid
          return valid, message
        end

        if value.respond_to?(:empty?) && value.empty?
          unless allow_empty?
            return [false, "does not allow an empty value"]
          end
        elsif value.respond_to?(:=~) && value =~ /\A\s+\z/
          unless allow_blank?
            return [false, "does not allow a blank value"]
          end
        end

        return true
      end

    end
  end
end
