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

