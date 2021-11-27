# command_mapper

[![CI](https://github.com/postmodern/command_mapper.rb/actions/workflows/ruby.yml/badge.svg)](https://github.com/postmodern/command_mapper.rb/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/postmodern/command_mapper.rb.svg)](https://codeclimate.com/github/postmodern/command_mapper.rb)
[![Gem Version](https://badge.fury.io/rb/command_mapper.svg)](https://badge.fury.io/rb/command_mapper)

* [Source](https://github.com/postmodern/command_mapper)
* [Issues](https://github.com/postmodern/command_mapper/issues)
* [Documentation](http://rubydoc.info/gems/command_mapper/frames)

## Description
  
Command Mapper maps a command's options and arguments to Class attributes to
allow safely and securely executing commands.

## Features

* Supports defining commands as Ruby classes.
* Supports mapping in options and additional arguments.
  * Supports common option types:
    * [Str][CommandMapper::Types::Str]: string values
    * [Num][CommandMapper::Types::Num]: numeric values
    * [Hex][CommandMapper::Types::Hex]: hexadecimal values
    * [Map][CommandMapper::Types::Map]: maps `true`/`false` to `yes`/`no`, or
      `enabled`/`disabled` (aka `--opt=yes|no` or
      `--opt=enabled|disabled` values).
    * [Enum][CommandMapper::Types::Enum]: maps a finite set of Symbols to a
      finite set of Strings (aka `--opt={foo|bar|baz}` values).
    * [List][CommandMapper::Types::List]: comma-separated list
      (aka `--opt VALUE,...`).
    * [KeyValue][CommandMapper::Types::KeyValue]: maps a Hash or Array to
      key:value Strings (aka `--opt KEY:VALUE` or `--opt KEY=VALUE` values).
    * [KeyValueList][CommandMapper::Types::KeyValueList]: a key-value list
      (aka `--opt KEY:VALUE,...` or  `--opt KEY=VALUE;...` values).
    * [InputPath][CommandMapper::Types::InputPath]: a path to a pre-existing
      file or directory
    * [InputFile][CommandMapper::Types::InputFile]: a path to a pre-existing
      file
    * [InputDir][CommandMapper::Types::InputDir]: a path to a pre-existing
      directory
* Supports mapping in sub-commands.
* Allows running the command via `IO.popen` to read the command's output.
* Allows running commands with additional environment variables.
* Allows overriding the command name or path to the command.
* Allows running commands via `sudo`.
* Prevents command injection and option injection.

[CommandMapper::Types::Str]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/Str
[CommandMapper::Types::Num]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/Num
[CommandMapper::Types::Hex]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/Hex
[CommandMapper::Types::Map]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/Map
[CommandMapper::Types::Enum]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/Enum
[CommandMapper::Types::List]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/List
[CommandMapper::Types::KeyValue]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/KeyValue
[CommandMapper::Types::KeyValueList]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/KeyValueList
[CommandMapper::Types::InputPath]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/InputPath
[CommandMapper::Types::InputFile]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/InputFile
[CommandMapper::Types::InputDir]: https://rubydoc.info/gems/command_mapper/CommandMapper/Types/InputDir

## Examples

```ruby
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
    option "-I", name: 	# FIXME: name
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
```

### Defining Options

```ruby
option "--opt"
```

Define a short option:

```ruby
option "-o", name: :opt
```

Defines an option with a required value:

```ruby
option "--output", value: {required: true}
```

Defines an option that can be specified multiple times:

```ruby
option "--include-dir", repeats: true
```

Defines an option that accepts a numeric value:

```ruby
option "--count", value: {type: Num.new}
```

Defines an option that accepts a comma-separated list:

```ruby
option "--list", value: {type: List.new}
```

Defines an option that accepts a `key=value` pair:

```ruby
option "--param", value: {type: KeyValue.new}
```

Defines an option that accepts a `key:value` pair:

```ruby
option "--param", value: {type: KeyValue.new(separator: ':')}
```

Defines an option that accepts a finite number of values:

```ruby
option "--type", value: {type: Enum[:foo, :bar, :baz]}
```

Custom methods:

```ruby
def foo
  @foo || @bar
end

def foo=(value)
  @foo = case value
         when Hash  then ...
         when Array then ...
         else            value.to_s
         end
end
```

### Defining Arguments

```ruby
argument :host
```

Define an optional argument:

```ruby
argument :optional_output, required: false
```

Define an argument that can be repeated:

```ruby
argument :files, repeats: true
```

Define an argument that accepts an existing file:

```ruby
argument :file, type: InputFile.new
```

Define an argument that accepts an existing directory:

```ruby
argument :dir, type: InputDir.new
```

Custom methods:

```ruby
def foo
  @foo || @bar
end

def foo=(value)
  @foo = case value
         when Hash  then ...
         when Array then ...
         else            value.to_s
         end
end
```

### Custom Types

```ruby
class PortRange < CommandMapper::Types::Type

  def validate(value)
    case value
    when Integer
      true
    when Range
      if value.begin.kind_of?(Integer)
        true
      else
        [false, "port range can only contain Integers"]
      end
    else
      [false, "port range must be an Integer or a Range of Integers"]
    end
  end

  def format(value)
    case value
    when Integer
      "#{value}"
    when Range
      "#{value.begin}-#{value.end}"
    end
  end

end

option :ports, value: {required: true, type: PortRange.new}
```

### Running

Keyword arguments:

```ruby
Grep.run(ignore_case: true, patterns: "foo", file: "file.txt")
# ...
```

With a block:

```ruby
Grep.run do |grep|
  grep.ignore_case = true
  grep.patterns    = "foo"
  grep.file        = "file.txt"
end
```

### Capturing output

```ruby
Grep.capture(ignore_case: true, patterns: "foo", file: "file.txt")
# => "..."
```

### popen

```ruby
io = Grep.popen(ignore_case: true, patterns: "foo", file: "file.txt")

io.each_line do |line|
  # ...
end
```

### sudo

```ruby
Grep.sudo(patterns: "Error", file: "/var/log/syslog")
# Password: 
# ...
```

### Code Gen

[command_mapper-gen] can automatically generate command classes from a command's
`--help` output and/or man page.

[command_mapper-gen]: https://github.com/postmodern/command_mapper-gen.rb#readme

```
$ gem install command_mapper-gen
$ command_mapper-gen cat
require 'command_mapper/command'

#
# Represents the `cat` command
#
class Cat < CommandMapper::Command

  command "cat" do
    option "--show-all"
    option "--number-nonblank"
    option "-e", name: 	# FIXME: name
    option "--show-ends"
    option "--number"
    option "--squeeze-blank"
    option "-t", name: 	# FIXME: name
    option "--show-tabs"
    option "-u", name: 	# FIXME: name
    option "--show-nonprinting"
    option "--help"
    option "--version"

    argument :file, required: false, repeats: true
  end

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
gem 'command_mapper', '~> 0.1'
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
