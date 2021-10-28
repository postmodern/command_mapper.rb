require 'spec_helper'
require 'command_mapper/argument'
require 'command_mapper/types/list'
require 'command_mapper/types/key_value'

describe CommandMapper::Argument do
  let(:name) { :foo }

  describe "#initialize" do
    subject { described_class.new(name) }

    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    it "must default #required? to true" do
      expect(subject.required?).to be(true)
    end

    it "must default #type to a Types::Str object" do
      expect(subject.type).to be_kind_of(Types::Str)
    end

    it "must default #repeats? to false" do
      expect(subject.repeats?).to be(false)
    end

    context "when given the required: false keyword argument" do
      subject { described_class.new(name, required: false) }

      it "must set #required? to false" do
        expect(subject.required?).to be(false)
      end
    end

    context "when given the type: keyword argument" do
      context "and it's a custom Types::Type class" do
        let(:type) { Types::KeyValue.new }

        subject { described_class.new(name, type: type) }

        it "must set #type" do
          expect(subject.type).to eq(type)
        end
      end
    end

    context "when given the repeats: true keyword argument" do
      subject { described_class.new(name, repeats: true) }

      it "#repeats? must be true" do
        expect(subject.repeats?).to be(true)
      end
    end
  end

  let(:required) { false }
  let(:repeats)  { false }
  let(:value_allows_empty) { false }
  let(:value_allows_blank) { false }
  let(:type) do
    {
      allow_empty: value_allows_empty,
      allow_blank: value_allows_blank
    }
  end

  subject do
    described_class.new(name, required: required,
                              type:     type,
                              repeats:  repeats)
  end

  describe "#validate" do
    context "when the argument requires a value" do
      let(:required) { true }

      context "and when the argument can be repeated" do
        let(:repeats) { true }

        context "is given an Array" do
          let(:value) { ["foo"] }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "but it's empty" do
            let(:value) { [] }

            it "must return false and a validation error message" do
              expect(subject.validate(value)).to eq(
                [false, "requires at least one value"]
              )
            end
          end
        end

        context "is given a single String" do
          let(:value) { "foo" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "is given nil" do
          let(:value) { nil }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "requires at least one value"]
            )
          end
        end
      end

      context "but the argument can only be specified once" do
        let(:repeats) { false }

        context "is given a single String" do
          let(:value) { "foo" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and when nil is given" do
          let(:value) { nil }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "does not allow a nil value"]
            )
          end
        end
      end
    end

    context "when the argument does not require a value" do
      let(:required) { false }

      context "and when the argument can be repeated" do
        let(:repeats) { true }

        context "is given an Array" do
          let(:value) { ["foo"] }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "but it's empty" do
            let(:value) { [] }

            it "must return false and a validation error message" do
              expect(subject.validate(value)).to be(true)
            end
          end
        end

        context "is given a single String" do
          let(:value) { "foo" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and when nil is given" do
          let(:value) { nil }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "but the argument can only be specified once" do
        let(:repeats) { false }

        context "is given an Array" do
          let(:value) { ["foo"] }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end

          context "but it's empty" do
            let(:value) { [] }

            it "must return false and a validation error message" do
              expect(subject.validate(value)).to eq(
                [false, "does not allow an empty value"]
              )
            end
          end
        end

        context "is given a single String" do
          let(:value) { "foo" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end

        context "and when nil is given" do
          let(:value) { nil }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end
    end
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

        context "when initializes with a custom type: type" do
          let(:type) { Types::KeyValue.new }

          let(:values) do
            [{"foo" => 1}, {"bar" => 2 }]
          end

          it "must format each value using #type.format" do
            expect(subject.argv(values)).to eq(
              [
                subject.type.format(values[0]),
                subject.type.format(values[1])
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

        context "when initializes with a custom type: type" do
          let(:type) { Types::KeyValue.new }

          let(:value) do
            {"foo" => "bar"}
          end

          it "must format the value using #type.format" do
            expect(subject.argv(value)).to eq([subject.type.format(value)])
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

      context "and is given nil" do
        let(:value) { nil }

        it "must return an empty argv" do
          expect(subject.argv(value)).to eq([])
        end
      end

      context "when initializes with a custom type: type" do
        let(:type)  { Types::List.new }
        let(:value) { [1,2,3,4]       }

        it "must format the value using #value.format" do
          expect(subject.argv(value)).to eq([subject.type.format(value)])
        end
      end
    end

    context "when the given value is invalid" do
      let(:value)   { "  " }
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
