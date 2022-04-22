require 'command_mapper/command'

#
# Represents the `grep` command
#
class Grep < CommandMapper::Command

  command "grep" do
    option "--extended-regexp"
    option "--fixed-strings"
    option "--basic-regexp"
    option "--perl-regexp"
    option "--regexp", equals: true, value: true
    option "--file", name: :patterns_file, equals: true, value: true
    option "--ignore-case"
    option "--no-ignore-case"
    option "--word-regexp"
    option "--line-regexp"
    option "--null-data"
    option "--no-messages"
    option "--invert-match"
    option "--version"
    option "--help"
    option "--max-count", equals: true, value: {type: Num.new}
    option "--byte-offset"
    option "--line-number"
    option "--line-buffered"
    option "--with-filename"
    option "--no-filename"
    option "--label", equals: true, value: true
    option "--only-matching"
    option "--quiet"
    option "--binary-files", equals: true, value: true
    option "--text"
    option "-I", name: :binary
    option "--directories", equals: true, value: true
    option "--devices", equals: true, value: true
    option "--recursive"
    option "--dereference-recursive"
    option "--include", equals: true, value: true
    option "--exclude", equals: true, value: true
    option "--exclude-from", equals: true, value: true
    option "--exclude-dir", equals: true, value: true
    option "--files-without-match", value: true
    option "--files-with-matches"
    option "--count"
    option "--initial-tab"
    option "--null"
    option "--before-context", equals: true, value: {type: Num.new}
    option "--after-context", equals: true, value: {type: Num.new}
    option "--context", equals: true, value: {type: Num.new}
    option "--group-separator", equals: true, value: true
    option "--no-group-separator"
    option "--color", equals: :optional, value: {required: false}
    option "--colour", equals: :optional, value: {required: false}
    option "--binary"

    argument :patterns
    argument :file, required: false, repeats: true
  end

end
