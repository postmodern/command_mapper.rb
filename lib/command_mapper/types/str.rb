require 'command_mapper/types/type'

module CommandMapper
  module Types
    class Str < Type
      #
      # Initializes the value.
      #
      # @param [Boolean] allow_empty
      #   Specifies whether the argument may accept empty values.
      #
      # @param [Boolean] allow_blank
      #   Specifies whether the argument may accept blank values.
      #
      def initialize(allow_empty: false, allow_blank: false)
        @allow_empty = allow_empty
        @allow_blank = allow_blank
      end

      #
      # Specifies whether the option's value may accept empty values.
      #
      # @return [Boolean]
      #
      # @api semipublic
      #
      def allow_empty?
        @allow_empty
      end

      #
      # Specifies whether the option's value may accept blank values.
      #
      # @return [Boolean]
      #
      # @api semipublic
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
      #   Returns true if the value is considered valid, or false and a
      #   validation message if the value is not valid.
      #   * If `nil` is given and a value is required, then `false` will be
      #     returned.
      #   * If an empty value is given and empty values are not allowed, then
      #     `false` will be returned.
      #   * If an empty value is given and blank values are not allowed, then
      #     `false` will be returned.
      #
      # @api semipublic
      #
      def validate(value)
        case value
        when nil
          unless allow_empty?
            return [false, "cannot be nil"]
          end
        when Enumerable
          return [false, "cannot convert a #{value.class} into a String (#{value.inspect})"]
        else
          unless value.respond_to?(:to_s)
            return [false, "does not define a #to_s method (#{value.inspect})"]
          end

          string = value.to_s

          if string.empty?
            unless allow_empty?
              return [false, "does not allow an empty value"]
            end
          elsif string =~ /\A\s+\z/
            unless allow_blank?
              return [false, "does not allow a blank value (#{value.inspect})"]
            end
          end
        end

        return true
      end

    end
  end
end
