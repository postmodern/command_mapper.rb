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
      context "and it's a Types::Type object" do
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

  let(:required) { true  }
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

      context "when the argument can be specified multiple times" do
        let(:repeats) { true }

        context "and it's given an Array" do
          context "and all elements of the Array are Strings" do
            let(:value) { %w[foo bar baz] }

            it "must return true" do
              expect(subject.validate(value)).to be(true)
            end
          end

          context "but one of the Array's elements is nil" do
            let(:values) { ["foo", nil, "bar"] }

            it "must return [false, \"cannot be nil\"]" do
              expect(subject.validate(values)).to eq(
                [false, "cannot be nil"]
              )
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

            context "but #type is a Types::KeyValue object" do
              let(:type) { Types::KeyValue.new }

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

        context "is given a String" do
          let(:value) { "foo" }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
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

            context "but #type is a Types::KeyValue object" do
              let(:type) { Types::KeyValue.new }

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

      context "but the argument can only be specified once" do
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

          context "when #type is a Types::List object" do
            let(:type) { Types::List.new }

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

          context "but #type is a Types::KeyValue object" do
            let(:type) { Types::KeyValue.new }

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
  end

  describe "#argv" do
    context "when the argument can be specified multiple times" do
      let(:repeats) { true }

      context "and it's given an Array" do
        context "and all elements of the Array are Strings" do
          let(:values) { %w[foo bar baz] }

          it "must return an argv of the values" do
            expect(subject.argv(values)).to eq(values)
          end

          context "but one of the Array's elements is nil" do
            let(:values) { ["foo", nil, "bar"] }

            it do
              expect {
                subject.argv(values)
              }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{values.inspect}): cannot be nil")
            end
          end

          context "but one of the Array's elements is invalid" do
            let(:value) { ["foo", " ", "baz"] }

            it do
              expect {
                subject.argv(value)
              }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): does not allow a blank value (#{value[1].inspect})")
            end
          end

          context "but the Array contains Hashes" do
            let(:values) do
              [{"foo" => 1}, {"bar" => 2 }]
            end

            it do
              expect {
                subject.argv(values)
              }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{values.inspect}): cannot convert a Hash into a String (#{values[0].inspect})")
            end

            context "but #type is a Types::KeyValue object" do
              let(:type) { Types::KeyValue.new }

              it "must format each value using #type.format" do
                expect(subject.argv(values)).to eq(
                  [
                    subject.type.format(values[0]),
                    subject.type.format(values[1])
                  ]
                )
              end

              context "but one of the Hashes is empty" do
                let(:values) do
                  [{"foo" => 1}, {}]
                end

                it do
                  expect {
                    subject.argv(values)
                  }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{values.inspect}): cannot be empty")
                end
              end
            end
          end

          context "but it's empty" do
            let(:value) { [] }

            it do
              expect {
                subject.argv(value)
              }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): requires at least one value")
            end
          end
        end
      end
    end

    context "and it's only given one value" do
      context "and it's a String" do
        let(:value) { "foo" }

        it "must return an argv only containing the value" do
          expect(subject.argv(value)).to eq([value])
        end

        context "but the String is invalid" do
          let(:value) { " " }

          it do
            expect {
              subject.argv(value)
            }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): does not allow a blank value (#{value.inspect})")
          end
        end
      end

      context "and it's a Hash" do
        let(:value) do
          {"foo" => "bar"}
        end

        context "but #type is a Types::KeyValue object" do
          let(:type) { Types::KeyValue.new }

          it "must format the value using #type.format" do
            expect(subject.argv(value)).to eq(
              [subject.type.format(value)]
            )
          end

          context "but it's empty" do
            let(:value) { {} }

            it do
              expect {
                subject.argv(value)
              }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): cannot be empty")
            end
          end
        end
      end
    end
  end

  context "when the argument can only be specified once" do
    let(:repeats) { false }

    context "and it's a String" do
      let(:value)   { "foo" }

      it "must return an argv only containing the value" do
        expect(subject.argv(value)).to eq([value])
      end
    end

    context "and it's an Array" do
      let(:value) { %w[foo bar baz] }

      it do
        expect {
          subject.argv(value)
        }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): cannot convert a Array into a String (#{value.inspect})")
      end

      context "but #type is a Types::List object" do
        let(:type) { Types::List.new }

        it "must format the value using #type.format" do
          expect(subject.argv(value)).to eq(
            [subject.type.format(value)]
          )
        end

        context "but one of the Array elements is nil" do
          let(:value) { [1,2,nil,4] }

          it do
            expect {
              subject.argv(value)
            }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): element cannot be nil")
          end
        end

        context "but one of the Array's elements is invalid" do
          let(:value)   { ["foo", " ", "baz"] }
          let(:message) { "does not allow a blank value" }

          it do
            expect {
              subject.argv(value)
            }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): element does not allow a blank value (#{value[1].inspect})")
          end
        end

        context "but it's empty" do
          let(:value) { [] }

          it do
            expect {
              subject.argv(value)
            }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): cannot be empty")
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
        }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): cannot convert a Hash into a String (#{value.inspect})")
      end

      context "but #type is a Types::KeyValue object" do
        let(:type) { Types::KeyValue.new }

        it "must format the value using #type.format" do
          expect(subject.argv(value)).to eq(
            [subject.type.format(value)]
          )
        end

        context "but it's empty" do
          let(:value) { {} }

          it do
            expect {
              subject.argv(value)
            }.to raise_error(ValidationError,"argument #{name} was given an invalid value (#{value.inspect}): cannot be empty")
          end
        end
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
