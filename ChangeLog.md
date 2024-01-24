### 0.3.2 / 2024-01-23

* Switch to use `require_relative` to improve load-times.
* Allow passing `sudo` specific keyword arguments in
  {CommandMapper::Command#sudo_command} to {CommandMapper::Sudo.run}.
* Allow {CommandMapper::Sudo}'s `preserve_env` attribute to accept an optional
  value.

### 0.3.1 / 2022-12-25

* Use `File.exist?` in {CommandMapper::Types::InputPath#validate} for Ruby
  3.2.0.

### 0.3.0 / 2022-11-11

* Added {CommandMapper::Types::Dec}.

### 0.2.1 / 2022-04-22

* Properly validate in {CommandMapper::OptionValue#validate} when an option,
  who's value is not required, is given `true`.
* Omit `nil` arguments from {CommandMapper::Command#command_argv} if the
  argument is not required.
* Improve validation error message for {CommandMapper::Types::Num} when
  initialized with a `range:` value.
* Improve validation error message for {CommandMapper::Types::Map} and 
  {CommandMapper::Types::Enum}.

### 0.2.0 / 2022-04-18

* Added {CommandMapper::Command.spawn} and
  {CommandMapper::Command#spawn_command}.
* Added checks to {CommandMapper::Command.option},
  {CommandMapper::Command.argument}, and {CommandMapper::Command.subcommand} to
  avoid overwriting an existing option/argument/subcommand with the same name.
* Added the `value_in_flag:` keyword argument to
  {CommandMapper::Command.option} which indicates an option's value
  should be appended to the flag (ex: `-Fvalue`).
* Added the `range:` keyword argument to {CommandMapper::Types::Num#initialize}
  for specifying the acceptable range of numbers.
* Allow options with `equals: true` (aka `--opt=...`) or `value_in_flag: true`
  (aka `-Fvalue`) to accept values that start with a `-` character.

### 0.1.2 / 2021-11-29

* Fixed a bug where {CommandMapper::Command.command_name} was not checking the
  superclass for the {CommandMapper::Command.command_name command_name}, if no
  `command "..."` was defined in the subclass.

### 0.1.1 / 2021-11-29

* Fixed a bug where {CommandMapper::Types::Num}, {CommandMapper::Types::Hex},
  {CommandMapper::Types::Enum}, {CommandMapper::Types::InputPath},
  {CommandMapper::Types::InputFile}, and {CommandMapper::Types::InputDir} were
  not being required by default.
* Allow {CommandMapper::Types::Map} to accept values that have already been
  mapped to a String.

### 0.1.0 / 2021-11-25

* Initial release:
  * Added {CommandMapper::Error}.
  * Added {CommandMapper::ValidationError}.
  * Added {CommandMapper::ArgumentRequired}.
  * Added {CommandMapper::Types::Type}.
  * Added {CommandMapper::Types::Str}.
  * Added {CommandMapper::Types::Num}.
  * Added {CommandMapper::Types::Hex}.
  * Added {CommandMapper::Types::Map}.
  * Added {CommandMapper::Types::Enum}.
  * Added {CommandMapper::Types::InputPath}.
  * Added {CommandMapper::Types::InputFile}.
  * Added {CommandMapper::Types::InputDir}.
  * Added {CommandMapper::Types::List}.
  * Added {CommandMapper::Types::KeyValue}.
  * Added {CommandMapper::Types::KeyValueList}.
  * Added {CommandMapper::Arg}.
  * Added {CommandMapper::Argument}.
  * Added {CommandMapper::OptionValue}.
  * Added {CommandMapper::Option}.
  * Added {CommandMapper::Command}.
  * Added {CommandMapper::Sudo}.

