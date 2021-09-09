# command_mapper

* [Source](https://github.com/postmodern/command_mapper)
* [Issues](https://github.com/postmodern/command_mapper/issues)
* [Documentation](http://rubydoc.info/gems/command_mapper/frames)

## Description
  
Command Mapper maps a command's arguments to Class attributes to allow easily
and safely automating commands.

## Features

* Supports defining commands as Ruby classes.
* Supports mapping in options and additional arguments.
  * Supports common option formats:
    * `List`: `VALUE,...`
    * `KeyValue`: `KEY:VALUE` or `KEY=VALUE`
    * `Map`: `enabled|disables` or `yes|no`
* Supports mapping in sub-commands.
* Safely executes commands and their individual command-line arguments,
  in order to prevent command or option injection.
* Allows running the command via `IO.popen` to read the command's output.
* Allows running commands with additional environment variables.
* Allows overriding the command name or path to the command.
* Allows running commands via `sudo`.

## Examples

```ruby
require 'command_mapper/command'

#
# Represents the `grep` command
#
class Grep < CommandMapper::Command

  command "grep"

  option "--extended-regexp"
  option "--fixed-strings"
  option "--basic-regexp"
  option "--perl-regexp"
  option "--regexp", equals: true, value: true
  option "--file", equals: true, value: true
  option "--ignore-case"
  option "--no-ignore-case"
  option "--word-regexp"
  option "--line-regexp"
  option "--null-data"
  option "--no-messages"
  option "--invert-match"
  option "--version"
  option "--help"
  option "--max-count", equals: true, value: true
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
  option "-I", name: :ignore_binary
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
  option "--before-context", equals: true, value: true
  option "--after-context", equals: true, value: true
  option "--context", equals: true, value: true
  option "--group-separator", equals: true, value: true
  option "--no-group-separator"
  option "--color", equals: :optional, value: {required: false}
  option "--colour", equals: :optional, value: {required: false}
  option "--binary"

  argument :patterns
  argument :file, required: false

end
```

## Requirements

* [ruby] >= 2.0.0

## Install

```shell
$ gem install command_mapper
```

### Gemfile

```ruby
gem 'command_mapper'
```

### gemspec

```ruby
gemspec.add_dependency 'command_mapper', '~> 0.1'
```

## License

Copyright (c) 2021 Hal Brodigan

See {file:LICENSE.txt} for license information.

[command_mapper]: https://github.com/postmodern/command_mapper.rb#readme
[ruby]: https://www.ruby-lang.org/
