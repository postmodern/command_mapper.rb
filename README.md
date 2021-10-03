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
  * Supports common option types:
    * `Num`: numeric values
    * `Hex`: hexadecimal values
    * `List`: `VALUE,...`
    * `KeyValue`: `KEY:VALUE` or `KEY=VALUE`
    * `Map`: `enabled|disables` or `yes|no`
    * `InputPath`: a path to a pre-existing file or directory
    * `InputFile`: a path to a pre-existing file
    * `InputDir`: a path to a pre-existing directory
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
  option "--regexp", equals: true, value: :required
  option "--file", equals: true, value: :required
  option "--ignore-case"
  option "--no-ignore-case"
  option "--word-regexp"
  option "--line-regexp"
  option "--null-data"
  option "--no-messages"
  option "--invert-match"
  option "--version"
  option "--help"
  option "--max-count", equals: true, value: :required
  option "--byte-offset"
  option "--line-number"
  option "--line-buffered"
  option "--with-filename"
  option "--no-filename"
  option "--label", equals: true, value: :required
  option "--only-matching"
  option "--quiet"
  option "--binary-files", equals: true, value: :required
  option "--text"
  option "-I", name: :ignore_binary
  option "--directories", equals: true, value: :required
  option "--devices", equals: true, value: :required
  option "--recursive"
  option "--dereference-recursive"
  option "--include", equals: true, value: :required
  option "--exclude", equals: true, value: :required
  option "--exclude-from", equals: true, value: :required
  option "--exclude-dir", equals: true, value: :required
  option "--files-without-match", value: :required
  option "--files-with-matches"
  option "--count"
  option "--initial-tab"
  option "--null"
  option "--before-context", equals: true, value: :required
  option "--after-context", equals: true, value: :required
  option "--context", equals: true, value: :required
  option "--group-separator", equals: true, value: :required
  option "--no-group-separator"
  option "--color", equals: :optional, value: :optional
  option "--colour", equals: :optional, value: :optional
  option "--binary"

  argument :patterns
  argument :file, value: :optional

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
option "--output", value: :required
```

Defines an option that can be specified multiple times:

```ruby
option "--include-dir", repeats: true
```

Defines an option that accepts a numeric value:

```ruby
option "--count", value: Num.new
```

Defines an option that accepts a comma-separated list:

```ruby
option "--list", value: List.new
```

Defines an option that accepts a `key=value` pair:

```ruby
option "--param", value: KeyValue.new
```

Defines an option that accepts a `key:value` pair:

```ruby
option "--param", value: KeyValue.new(separator: ':')
```

Custom writer methods:

```ruby
def foo=(value)
  @options[:foo] = case value
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
argument :optional_output, value: :optional
```

Define an argument that can be repeated:

```ruby
argument :files, repeats: true
```

Define an argument that accepts a file:

```ruby
argument :file, value: FilePath.new
```

Define an argument that accepts a directory:

```ruby
argument :dir, value: DirPath.new
```

Custom writer methods:

```ruby
def foo=(value)
  @arguments[:foo] = case value
                     when Hash  then ...
                     when Array then ...
                     else            value.to_s
                     end
end
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
  grep.patterns = "foo"
  grep.file = "file.txt"
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
