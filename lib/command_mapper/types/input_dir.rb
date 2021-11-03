require 'command_mapper/types/input_path'

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
      #
      # @return [true, (false, String)]
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
