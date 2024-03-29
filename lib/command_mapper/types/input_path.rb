require_relative 'type'

module CommandMapper
  module Types
    #
    # Represents a path to an existing file or a directory.
    #
    class InputPath < Type

      #
      # Validates whether the path exists or not.
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
        unless value.empty?
          unless File.exist?(value)
            return [false, "path does not exist (#{value.inspect})"]
          end
        end

        return true
      end

    end
  end
end
