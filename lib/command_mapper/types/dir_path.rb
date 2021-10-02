require 'command_mapper/types/value'

module CommandMapper
  module Types
    #
    # Represents a path to an existing directory.
    #
    class DirPath < Value

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
          unless File.directory?(value)
            return false, "directory does not exist"
          end
        end

        return true
      end

    end
  end
end
