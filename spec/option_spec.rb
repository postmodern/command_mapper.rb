require 'spec_helper'
require 'command_mapper/option'
require 'command_mapper/types/list'
require 'command_mapper/types/key_value'

describe CommandMapper::Option do
  describe "#initialize" do
    let(:flag) { '--foo' }

    subject { described_class.new(flag) }

    it "must set #flag" do
      expect(subject.flag).to eq(flag)
    end

    context "when a name: keyword argument is given" do
      let(:name) { :bar }

      subject { described_class.new(flag, name: name) }

      it "must set #name" do
        expect(subject.name).to eq(name)
      end
    end

    context "when no name: keyword argument is given" do
      it "must default #name to .infer_name_from_flag" do
        expect(subject.name).to eq(described_class.infer_name_from_flag(flag))
      end
    end

    it "must default #repeats? to false" do
      expect(subject.repeats?).to be(false)
    end

    context "when equals: true is given" do
      subject { described_class.new(flag, equals: true) }

      it "#equals? must return true" do
        expect(subject.equals?).to be(true)
      end
    end

    context "when given the repeats: true keyword argument" do
      subject { described_class.new(flag, repeats: true) }

      it "#repeats? must be true" do
        expect(subject.repeats?).to be(true)
      end
    end

    context "when value: is given" do
      context "and when value: is true" do
        subject { described_class.new(flag, value: true) }

        it "must initialize #value as an OptionValue" do
          expect(subject.value).to be_kind_of(OptionValue)
        end

        it "must set #value.required? to true" do
          expect(subject.value.required?).to be(true)
        end
      end

      context "and when value: is a Hash" do
        let(:value_required) { true }
        let(:value_type)     { Types::KeyValue.new }
        let(:value_kwargs) do
          {
            required: value_required,
            type:     value_type
          }
        end

        subject { described_class.new(flag, value: value_kwargs) }

        it "must initialize #value as an OptionValue" do
          expect(subject.value).to be_kind_of(OptionValue)
        end

        it "must initialize #value with the value: ... Hash" do
          expect(subject.value.required?).to be(value_required)
          expect(subject.value.type).to eq(value_type)
        end
      end
    end
  end

  describe ".infer_name_from_flag" do
    subject { described_class.infer_name_from_flag(flag) }

    context "when given a long flag" do
      let(:name) { "foo"       }
      let(:flag) { "--#{name}" }

      it "must return the flag name as a Symbol" do
        expect(subject).to eq(name.to_sym)
      end

      context "when the flag contains a '-'" do
        let(:flag) { '--foo-bar' }

        it "must convert all '-' characters to '_'" do
          expect(subject).to eq(:foo_bar)
        end
      end

      context "when the flag contains multiple '-'" do
        let(:flag) { '--foo--bar' }

        it "must replace multiple '-' characters with a single '_'" do
          expect(subject).to eq(:foo_bar)
        end
      end

      context "when the flag contains multiple '_'" do
        let(:flag) { '--foo__bar' }

        it "must replace multiple '_' characters with a single '_'" do
          expect(subject).to eq(:foo_bar)
        end
      end
    end

    context "when given a short flag" do
      context "when the flag length is 1" do
        let(:flag) { '-x' }

        it "must raise an ArgumentError" do
          expect {
            described_class.infer_name_from_flag(flag)
          }.to raise_error(ArgumentError,"cannot infer a name from short option flag: #{flag.inspect}")
        end
      end

      context "when the flag length is 2" do
        let(:flag) { '-ip' }

        it "must return the flag name without the '-'" do
          expect(subject).to eq(:ip)
        end
      end

      context "when the flag contains uppercase characters" do
        let(:flag) { '-Ip' }

        it "must convert all uppercase characters to lowercase" do
          expect(subject).to eq(:ip)
        end
      end

      context "when the flag length is > 2" do
        context "when the flag contains a '-'" do
          let(:flag) { '-foo-bar' }

          it "must convert all '-' characters to '_'" do
            expect(subject).to eq(:foo_bar)
          end
        end

        context "when the flag contains multiple '-'" do
          let(:flag) { '-foo--bar' }

          it "must replace multiple '-' characters with a single '_'" do
            expect(subject).to eq(:foo_bar)
          end
        end

        context "when the flag contains multiple '_'" do
          let(:flag) { '-foo__bar' }

          it "must replace multiple '_' characters with a single '_'" do
            expect(subject).to eq(:foo_bar)
          end
        end
      end
    end
  end

  describe "#accepts_value?" do
    context "when initialized with the value: keyword argument" do
      context "and when value: is true" do
        subject { described_class.new(flag, value: true) }

        it "must return true" do
          expect(subject.accepts_value?).to be(true)
        end
      end

      context "and when value: is a Hash" do
        let(:value_required) { true }
        let(:value_type)     { Types::KeyValue.new }
        let(:value_kwargs) do
          {
            required: value_required,
            type:     value_type
          }
        end

        subject { described_class.new(flag, value: value_kwargs) }

        it "must return true" do
          expect(subject.accepts_value?).to be(true)
        end
      end
    end

    context "when not initialied with the value: keyword argument" do
      subject { described_class.new(flag) }

      it "must return false" do
        expect(subject.accepts_value?).to be(false)
      end
    end
  end

  describe "#equals?" do
    context "when initialized with equals: true" do
      subject { described_class.new(flag, value: true, equals: true) }

      it "must return true" do
        expect(subject.equals?).to be(true)
      end
    end

    context "when not initialized with equals: true" do
      subject { described_class.new(flag, value: true) }

      it "must return nil" do
        expect(subject.equals?).to be(nil)
      end
    end
  end

  let(:flag) { "--opt" }
  let(:name) { "opt" }

  let(:repeats) { false }
  let(:accepts_value) { false }

  let(:value_required) { true }
  let(:value_allows_empty) { false }
  let(:value_allows_blank) { false }
  let(:value_type) do
    {
      allow_empty: value_allows_empty,
      allow_blank: value_allows_blank
    }
  end
  let(:value_kwargs) do
    {
      required: value_required,
      type:     value_type
    }
  end

  let(:equals) { nil }

  subject do
    if accepts_value
      described_class.new(flag, name:    name,
                                value:   value_kwargs,
                                repeats: repeats,
                                equals:  equals)
    else
      described_class.new(flag, name: name, repeats: repeats)
    end
  end

  describe "#validate" do
    context "when the option accepts a value" do
      let(:accepts_value)  { true }
      let(:value_required) { true }

      context "when the option can be specified multiple times" do
        let(:repeats) { true }

        context "and is given an Array" do
          context "and all elements of the Array are Strings" do
            let(:values) { %w[foo bar baz] }

            it "must return true" do
              expect(subject.validate(values)).to be(true)
            end
          end

          context "but one of the Array's elements is nil" do
            let(:values) { ["foo", nil, "bar"] }

            it "must return [false, \"does not accept a nil value\"]" do
              expect(subject.validate(values)).to eq(
                [false, "does not accept a nil value"]
              )
            end

            context "but #value.required? is false" do
              let(:value_required) { false }

              it "must return true" do
                expect(subject.validate(values)).to be(true)
              end
            end
          end

          context "but the Array contains Hashes" do
            let(:values) do
              [{"foo" => 1}, {"bar" => 2 }]
            end

            it "must return [false, \"cannot convert a Hash into a String (...)\"]" do
              expect(subject.validate(values)).to eq(
                [false, "cannot convert a Hash into a String (#{values[0].inspect})"]
              )
            end

            context "but #value.type is a Types::KeyValue object" do
              let(:value_type) { Types::KeyValue.new }

              let(:values) do
                [{"foo" => 1}, {"bar" => 2 }]
              end

              it "must return true" do
                expect(subject.validate(values)).to be(true)
              end

              context "but one of the Hashes is empty" do
                let(:values) do
                  [{"foo" => 1}, {}]
                end

                it "must return [false, \"requires at least one value\"]" do
                  expect(subject.validate(values)).to eq(
                    [false, "cannot be empty"]
                  )
                end
              end
            end
          end

          context "but it's empty" do
            let(:value) { [] }

            it "must return [false, \"requires at least one value\"]" do
              expect(subject.validate(value)).to eq(
                [false, "requires at least one value"]
              )
            end
          end
        end

        context "and it's only given one value" do
          context "and it's a String" do
            let(:value) { "foo" }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end

          context "and it's a Hash" do
            let(:value) do
              {"foo" => "bar"}
            end

            it "must return [false, \"cannot convert a Hash into a String (...)\"]" do
              expect(subject.validate(value)).to eq(
                [false, "cannot convert a Hash into a String (#{value.inspect})"]
              )
            end

            context "but #value.type is a Types::KeyValue object" do
              let(:value_type) { Types::KeyValue.new }

              it "must return true" do
                expect(subject.validate(value)).to be(true)
              end

              context "but it's empty" do
                let(:value) { {} }

                it "must return [false, \"cannot be empty\"]" do
                  expect(subject.validate(value)).to eq(
                    [false, "cannot be empty"]
                  )
                end
              end
            end
          end
        end
      end

      context "when the option can only be specified once" do
        let(:repeats) { false }

        context "and is given a String" do
          let(:value) { "foo" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and is given an Array" do
          let(:value) { [1,2,3,4] }

          it "must return [false, \"cannot convert a Array into a String (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "cannot convert a Array into a String (#{value.inspect})"]
            )
          end

          context "when #value.type is a Types::List object" do
            let(:value_type) { Types::List.new }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end

            context "but one of the Array elements is nil" do
              let(:value) { [1,2,nil,4] }

              it "must return [false, \"element cannot be nil\"]" do
                expect(subject.validate(value)).to eq(
                  [false, "element cannot be nil"]
                )
              end
            end

            context "but it's empty" do
              let(:value) { [] }

              it "must return [false, \"cannot be empty\"]" do
                expect(subject.validate(value)).to eq(
                  [false, "cannot be empty"]
                )
              end
            end
          end
        end

        context "and it's a Hash" do
          let(:value) do
            {"foo" => "bar"}
          end

          it "must return [false, \"cannot convert a Hash into a String (...)\"]" do
            expect(subject.validate(value)).to eq(
              [false, "cannot convert a Hash into a String (#{value.inspect})"]
            )
          end

          context "but #value.type is a Types::KeyValue object" do
            let(:value_type) { Types::KeyValue.new }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end

            context "but it's empty" do
              let(:value) { {} }

              it "must return [false, \"cannot be empty\"]" do
                expect(subject.validate(value)).to eq(
                  [false, "cannot be empty"]
                )
              end
            end
          end
        end
      end
    end

    context "when the option does not accept a value" do
      let(:allows_value) { false }

      shared_examples "and a Boolean is given" do
        context "and is given true" do
          let(:value) { true }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and is given false" do
          let(:value) { false }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and is given nil" do
          let(:value) { nil }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

      end

      context "and when the option can be repeated" do
        let(:repeats) { true }

        context "and is given true" do
          let(:value) { true }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and is given false" do
          let(:value) { false }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and is given nil" do
          let(:value) { nil }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and is given an Integer" do
          let(:value) { 3 }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "but the option can only be specified once" do
        let(:repeats) { false }

        context "is given an Integer" do
          let(:value) { 3 }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "only repeating options may accept Integers"]
            )
          end
        end
      end
    end
  end

  describe "#argv" do
    context "when the option accepts a value" do
      let(:accepts_value) { true }

      context "when the option can be specified multiple times" do
        let(:repeats) { true }

        context "and it's given an Array" do
          context "and all elements of the Array are Strings" do
            let(:values) { %w[foo bar baz] }

            it "must return an argv of the option flags followed by values" do
              expect(subject.argv(values)).to eq(
                [
                  flag, values[0],
                  flag, values[1],
                  flag, values[2]
                ]
              )
            end

            context "and #equals? is true" do
              let(:equals) { true }

              it "must return an argv of option flag=value Strings" do
                expect(subject.argv(values)).to eq(
                  [
                    "#{flag}=#{values[0]}",
                    "#{flag}=#{values[1]}",
                    "#{flag}=#{values[2]}"
                  ]
                )
              end
            end

            context "but one of the Array's elements is invalid" do
              let(:value) { ["foo", " ", "baz"] }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): does not allow a blank value (#{value[1].inspect})")
              end
            end

            context "but one of the Array's elements starts with a '-'" do
              let(:value) { ["foo", "-bar", "baz"] }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} formatted value (#{value[1].inspect}) cannot start with a '-'")
              end
            end
          end

          context "but one of the Array's elements is true" do
            let(:values) { ["foo", true, "bar"] }

            context "but #value.required? is false" do
              let(:value_required) { false }

              it "must only emit the option's flag for true values" do
                expect(subject.argv(values)).to eq(
                  [
                    flag, values[0],
                    flag,
                    flag, values[2]
                  ]
                )
              end
            end
          end

          context "but the Array contains Hashes" do
            let(:values) do
              [{"foo" => 1}, {"bar" => 2 }]
            end

            it do
              expect {
                subject.argv(values)
              }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{values.inspect}): cannot convert a Hash into a String (#{values[0].inspect})")
            end

            context "but #value.type is a Types::KeyValue object" do
              let(:value_type) { Types::KeyValue.new }

              it "must format each value using #value.format" do
                expect(subject.argv(values)).to eq(
                  [
                    flag, subject.value.format(values[0]),
                    flag, subject.value.format(values[1])
                  ]
                )
              end

              context "and #equals? is true" do
                let(:equals) { true }

                it "must return an argv of option flag=value Strings" do
                  expect(subject.argv(values)).to eq(
                    [
                      "#{flag}=#{subject.value.format(values[0])}",
                      "#{flag}=#{subject.value.format(values[1])}"
                    ]
                  )
                end
              end

              context "but one of the Hashes is empty" do
                let(:values) do
                  [{"foo" => 1}, {}]
                end

                it do
                  expect {
                    subject.argv(values)
                  }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{values.inspect}): cannot be empty")
                end
              end

              context "but one of the Hash's keys starts with a '-'" do
                let(:value) { [{"foo" => 1}, {"-bar" => 2 }] }

                it do
                  expect {
                    subject.argv(value)
                  }.to raise_error(ValidationError,"option #{name} formatted value (\"-bar=2\") cannot start with a '-'")
                end
              end
            end
          end

          context "but it's empty" do
            let(:value) { [] }

            it do
              expect {
                subject.argv(value)
              }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): requires at least one value")
            end
          end
        end

        context "and it's only given one value" do
          context "and it's a String" do
            let(:value) { "foo" }

            it "must return an argv only containing the option flag and value" do
              expect(subject.argv(value)).to eq([flag, value])
            end

            context "and #equals? is true" do
              let(:equals) { true }

              it "must return an argv containing an option flag=value String" do
                expect(subject.argv(value)).to eq(["#{flag}=#{value}"])
              end
            end

            context "but it's invalid" do
              let(:value) { " " }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): does not allow a blank value (#{value.inspect})")
              end
            end

            context "but it starts with a '-'" do
              let(:value) { "-foo" }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} formatted value (#{value.inspect}) cannot start with a '-'")
              end
            end
          end

          context "and it's a Hash" do
            let(:value) do
              {"foo" => "bar"}
            end

            context "but #value.type is a Types::KeyValue object" do
              let(:value_type) { Types::KeyValue.new }

              it "must format the value using #value.format" do
                expect(subject.argv(value)).to eq(
                  [flag, subject.value.format(value)]
                )
              end

              context "and #equals? is true" do
                let(:equals) { true }

                it "must return an argv containing an option flag=value String" do
                  expect(subject.argv(value)).to eq(
                    ["#{flag}=#{subject.value.format(value)}"]
                  )
                end
              end

              context "but it's empty" do
                let(:value) { {} }

                it do
                  expect {
                    subject.argv(value)
                  }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): cannot be empty")
                end
              end

              context "but the key starts with a '-'" do
                let(:value) do
                  {"-foo" => "bar"}
                end

                it do
                  expect {
                    subject.argv(value)
                  }.to raise_error(ValidationError,"option #{name} formatted value (\"-foo=bar\") cannot start with a '-'")
                end
              end
            end
          end
        end
      end

      context "when the option can only be specified once" do
        let(:repeats) { false }

        context "and it's true" do
          let(:value) { true }

          context "but #value.required? is false" do
            let(:value_required) { false }

            it "must only emit the option's flag for true values" do
              expect(subject.argv(value)).to eq([flag])
            end
          end
        end

        context "and it's a String" do
          let(:value) { "foo" }

          it "must return an argv only containing the option flag and value" do
            expect(subject.argv(value)).to eq([flag, value])
          end

          context "and #equals? is true" do
            let(:equals) { true }

            it "must return an argv containing an option flag=value String" do
              expect(subject.argv(value)).to eq(["#{flag}=#{value}"])
            end
          end

          context "but it's invalid" do
            let(:value) { " " }

            it do
              expect {
                subject.argv(value)
              }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): does not allow a blank value (#{value.inspect})")
            end
          end

          context "but it starts with a '-'" do
            let(:value) { "-foo" }

            it do
              expect {
                subject.argv(value)
              }.to raise_error(ValidationError,"option #{name} formatted value (#{value.inspect}) cannot start with a '-'")
            end
          end
        end

        context "and it's an Array" do
          let(:value) { %w[foo bar baz] }

          it do
            expect {
              subject.argv(value)
            }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): cannot convert a Array into a String (#{value.inspect})")
          end

          context "but #value.type is a Types::List object" do
            let(:value_type) { Types::List.new }

            it "must format the value using #value.format" do
              expect(subject.argv(value)).to eq(
                [flag, subject.value.format(value)]
              )
            end

            context "and #equals? is true" do
              let(:equals) { true }

              it "must return an argv containing an option flag=value String" do
                expect(subject.argv(value)).to eq(
                  ["#{flag}=#{subject.value.format(value)}"]
                )
              end
            end

            context "but one of the Array's elements is nil" do
              let(:value) { ["foo", nil, "baz"] }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): element cannot be nil")
              end
            end

            context "but it's empty" do
              let(:value) { [] }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): cannot be empty")
              end
            end

            context "but the first element starts with a '-'" do
              let(:value) { ["-foo", "bar", "baz"] }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} formatted value (#{value.join(',').inspect}) cannot start with a '-'")
              end
            end
          end
        end

        context "and it's a Hash" do
          let(:value) do
            {"foo" => "bar"}
          end

          it do
            expect {
              subject.argv(value)
            }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): cannot convert a Hash into a String (#{value.inspect})")
          end

          context "but #value.type is a Types::KeyValue object" do
            let(:value_type) { Types::KeyValue.new }

            it "must format the value using #value.format" do
              expect(subject.argv(value)).to eq(
                [flag, subject.value.format(value)]
              )
            end

            context "and #equals? is true" do
              let(:equals) { true }

              it "must return an argv containing an option flag=value String" do
                expect(subject.argv(value)).to eq(
                  ["#{flag}=#{subject.value.format(value)}"]
                )
              end
            end

            context "but it's empty" do
              let(:value) { {} }

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): cannot be empty")
              end
            end

            context "but the first key starts with a '-'" do
              let(:value) do
                {"-foo" => "bar"}
              end

              it do
                expect {
                  subject.argv(value)
                }.to raise_error(ValidationError,"option #{name} formatted value (\"-foo=bar\") cannot start with a '-'")
              end
            end
          end
        end
      end
    end

    context "when the option does not accept a value" do
      let(:accepts_value) { false }

      context "and is given true" do
        it "must return an argv only containing the option's flag" do
          expect(subject.argv(true)).to eq([flag])
        end
      end

      context "and is given false" do
        it "must return an empty argv" do
          expect(subject.argv(false)).to eq([])
        end
      end

      context "and is given nil" do
        it "must return an empty argv" do
          expect(subject.argv(nil)).to eq([])
        end
      end

      context "and it's given a non-Boolean value" do
        let(:value) { "foo" }
        let(:message) { "only accepts true, false, or nil" }

        it do
          expect {
            subject.argv(value)
          }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): #{message}")
        end
      end

      context "and when the option can be specified multiple times" do
        let(:repeats) { true }

        context "and is given an Integer" do
          let(:value) { 3 }

          it "must return an argv containing multiple instances of the flag" do
            expect(subject.argv(value)).to eq([flag] * value)
          end
        end
      end
    end

    context "when given an argv array and a value" do
      let(:accepts_value) { true  }
      let(:value)         { "foo" }

      let(:argv) { [] }

      before { subject.argv(argv,value) }

      it "must concat the args to the argv array" do
        expect(argv).to eq([flag, value])
      end
    end
  end
end
