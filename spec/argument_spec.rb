require 'spec_helper'
require 'arg_examples'
require 'command_mapper/argument'
require 'command_mapper/types/list'
require 'command_mapper/types/key_value'

describe CommandMapper::Argument do
  include CommandMapper

  let(:name) { :foo }

  describe "#initialize" do
    subject { described_class.new(name) }

    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    it "must default #repeats? to false" do
      expect(subject.repeats?).to be(false)
    end

    context "when given the repeats: true keyword argument" do
      subject { described_class.new(name, repeats: true) }

      it "#repeats? must be true" do
        expect(subject.repeats?).to be(true)
      end
    end

    context "when given the value: keyword argument" do
      context "and it's a custom Types::Type class" do
        let(:value) { Types::KeyValue.new }

        subject { described_class.new(name, value: value) }

        it "must set #value" do
          expect(subject.value).to eq(value)
        end
      end

      context "when given a Hash" do
        context "when given the required: false keyword argument" do
          subject { described_class.new(name, value: {required: false}) }

          it "value's #required? must be true" do
            expect(subject.value.required?).to be(false)
          end
        end

        context "when given the required: false keyword argument" do
          subject { described_class.new(name, value: {required: false}) }

          it "the value's #required? must be false" do
            expect(subject.value.required?).to be(false)
          end
        end
      end
    end
  end

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
    described_class.new(name, value: value_type,
                              repeats: repeats)
  end

  describe "#validate" do
    include_examples "Arg#validate"
  end

  describe "#argv" do
    context "when the argument can be specified multiple times" do
      let(:repeats) { true }

      context "and it's given multiple values" do
        let(:values) { ["foo", "bar"] }

        it "must return an argv of the values" do
          expect(subject.argv(values)).to eq(values)
        end

        context "and the values contain nil values" do
          let(:values) { ["foo", nil, "bar"] }

          it "must filter out any nil values" do
            expect(subject.argv(values)).to eq([values[0], values[2]])
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
                subject.value.format(values[0]),
                subject.value.format(values[1])
              ]
            )
          end
        end
      end

      context "and it's only given one value" do
        let(:value) { "foo" }

        it "must return an argv only containing the value" do
          expect(subject.argv(value)).to eq([value])
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
            expect(subject.argv(value)).to eq([subject.value.format(value)])
          end
        end
      end
    end

    context "when the argument can only be specified once" do
      let(:repeats) { false }
      let(:value)   { "foo" }

      it "must return an argv only containing the value" do
        expect(subject.argv(value)).to eq([value])
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
          expect(subject.argv(value)).to eq([subject.value.format(value)])
        end
      end
    end

    context "when the given value is invalid" do
      let(:value) { "  " }
      let(:message) { "does not allow a blank value" }

      it do
        expect {
          subject.argv(value)
        }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): #{message}")
      end
    end

    context "when given an argv array and a value" do
      let(:value) { "foo" }

      let(:argv) { [] }

      before { subject.argv(argv,value) }

      it "must concat the args to the argv array" do
        expect(argv).to eq([value])
      end
    end
  end
end
