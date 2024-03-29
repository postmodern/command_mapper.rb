require_relative 'input_path'

module CommandMapper
  module Types
    #
    # Represents a path to an existing directory.
    #
    class InputDir < InputPath

      #
      # Validates whether the directory exists.
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
        valid, message = super(value)

        unless valid
          return valid, message
        end

        unless value.empty?
          unless File.directory?(value)
            return [false, "directory does not exist (#{value.inspect})"]
          end
        end

        return true
      end

    end
  end
end
