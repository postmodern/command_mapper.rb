require 'spec_helper'
require 'arg_examples'
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
      let(:value_options) { {required: true} }

      subject { described_class.new(flag, value: value_options) }

      it "must initialize #value with the value: options" do
        expect(subject.value).to be_kind_of(Types::Type)
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

  let(:flag) { "--opt" }
  let(:name) { "opt" }

  let(:repeats) { false }
  let(:accepts_value) { false }
  let(:value_required) { false }
  let(:value_allows_empty) { false }
  let(:value_allows_blank) { false }
  let(:value_type) do
    {
      required:    value_required,
      allow_empty: value_allows_empty,
      allow_blank: value_allows_blank
    }
  end

  subject do
    if accepts_value
      described_class.new(flag, name: name,
                                value: value_type,
                                repeats: repeats)
    else
      described_class.new(flag, name: name, repeats: repeats)
    end
  end

  describe "#validate" do
    include_examples "Arg#validate"

    context "when the option does not accept a value" do
      let(:allows_value) { false }

      shared_examples "when a Boolean is given" do
        context "is given true" do
          let(:value) { true }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "is given false" do
          let(:value) { false }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "is given nil" do
          let(:value) { nil }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

      end

      context "and when the option can be repeated" do
        let(:repeats) { true }

        include_examples "when a Boolean is given"

        context "is given an Integer" do
          let(:value) { 3 }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "but the option can only be specified once" do
        let(:repeats) { false }

        include_examples "when a Boolean is given"

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

        context "and it's given multiple values" do
          let(:values) { ["foo", "bar"] }

          it "must return an argv of the option flags followed by values" do
            expect(subject.argv(values)).to eq(
              [flag, values[0], flag, values[1]]
            )
          end

          context "and the values contain nil values" do
            let(:values) { ["foo", nil, "bar"] }

            it "must filter out any nil values" do
              expect(subject.argv(values)).to eq(
                [flag, values[0], flag, values[2]]
              )
            end
          end

          context "when initializes with a custom value: type" do
            let(:value_type) { Types::KeyValue.new }

            let(:values) do
              [{"foo" => 1}, {"bar" => 2 }]
            end

            it "must format each value using #value.format" do
              expect(subject.argv(values)).to eq(
                [
                  flag, subject.value.format(values[0]),
                  flag, subject.value.format(values[1])
                ]
              )
            end
          end
        end

        context "and it's only given one value" do
          let(:value) { "foo" }

          it "must return an argv only containing the option flag and value" do
            expect(subject.argv(value)).to eq([flag, value])
          end

          context "is given nil" do
            let(:value) { nil }

            it "must return an empty argv" do
              expect(subject.argv(value)).to eq([])
            end
          end

          context "when initializes with a custom value: type" do
            let(:value_type) { Types::KeyValue.new }

            let(:value) do
              {"foo" => "bar"}
            end

            it "must format the value using #value.format" do
              expect(subject.argv(value)).to eq(
                [flag, subject.value.format(value)]
              )
            end
          end
        end
      end

      context "when the option can only be specified once" do
        let(:repeats) { false }
        let(:value)   { "foo" }

        it "must return an argv only containing the option flag and value" do
          expect(subject.argv(value)).to eq([flag, value])
        end

        context "is given nil" do
          let(:value) { nil }

          it "must return an empty argv" do
            expect(subject.argv(value)).to eq([])
          end
        end

        context "when initializes with a custom value: type" do
          let(:value_type) { Types::List.new }
          let(:value)      { [1,2,3,4]       }

          it "must format the value using #value.format" do
            expect(subject.argv(value)).to eq([flag, subject.value.format(value)])
          end
        end
      end

      context "when the given value is invalid" do
        let(:value) { "  " }
        let(:message) { "does not allow a blank value" }

        it do
          expect {
            subject.argv(value)
          }.to raise_error(ValidationError,"option #{name} was given an invalid value (#{value.inspect}): #{message}")
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
