module CommandMapper
  #
  # Value logic.
  #
  module Value
    #
    # Determines if the value is nil.
    #
    # @param [Object] value
    #
    # @return [Boolean]
    #   The return value of the value's `nil?`.
    #
    def self.is_nil?(value)
      value.nil?
    end

    #
    # Determines if the value is empty.
    #
    # @param [Object] value
    #
    # @return [Boolean]
    #   Returns true if the value is non-nil, or if the value responds to
    #   `empty?` and `empty?` returns `true`.
    #
    def self.is_empty?(value)
      if value.respond_to?(:empty?) then value.empty?
      else                               value.nil?
      end
    end

    #
    # Determines if the value is a boolean value.
    #
    # @param [Object] value
    #
    # @return [Boolean]
    #   Returns `true` if the value is `true`, `false`, or `nil`.
    #   Otherwise returns `false`.
    #
    def self.is_boolean?(value)
      (value == true) || (value == false) || (value == nil)
    end
  end
end
