require 'command_mapper/types/value'

module CommandMapper
  module Types
    #
    # Represents a path to an existing file.
    #
    class FilePath < Value

      #
      # Validates the given value.
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
      end

    end
  end
end
