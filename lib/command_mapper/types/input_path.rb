require 'command_mapper/types/type'

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
      #
      # @return [true, (false, String)]
      #
      def validate(value)
        unless value.empty?
          unless File.exists?(value)
            return false, "path does not exist"
          end
        end

        return true
      end

    end
  end
end
