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
      #
      # @return [true, (false, String)]
      #
      def validate(value)
        valid, message = super(value)

        unless valid
          return valid, message
        end

        unless value.empty?
          unless File.file?(value)
            return false, "file does not exist"
          end
        end

        return true
      end

    end
  end
end
