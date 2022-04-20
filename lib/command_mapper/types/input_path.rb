require 'command_mapper/types/type'

module CommandMapper
  module Types
    #
    # Represents a path to an existing file or a directory.
    #
    # @api semipublic
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
      def validate(value)
        unless value.empty?
          unless File.exists?(value)
            return [false, "path does not exist (#{value.inspect})"]
          end
        end

        return true
      end

    end
  end
end
