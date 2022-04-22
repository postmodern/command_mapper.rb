require 'command_mapper/types/input_path'

module CommandMapper
  module Types
    #
    # Represents a path to an existing file.
    #
    class InputFile < InputPath

      #
      # Validates the file exists.
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
          unless File.file?(value)
            return [false, "file does not exist (#{value.inspect})"]
          end
        end

        return true
      end

    end
  end
end
