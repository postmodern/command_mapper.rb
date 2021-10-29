require 'spec_helper'
require 'command_mapper/types/list'
require 'command_mapper/types/num'

describe CommandMapper::Types::List do
  describe "#initialize" do
    it "must default #separator to ','" do
      expect(subject.separator).to eq(',')
    end

    context "when given the separator: keyword" do
      let(:separator) { ':' }

      subject { described_class.new(separator: separator) }

      it "must set #separator" do
        expect(subject.separator).to eq(separator)
      end
    end

    context "when given type: keyword argument" do
      context "and it's a Types::Type object" do
        let(:type) { Types::Num.new }

        subject { described_class.new(type: type) }

        it "must set a custom #type" do
          expect(subject.type).to eq(type)
        end
      end

      context "but it's nil" do
        it do
          expect {
            described_class.new(type: nil)
          }.to raise_error(ArgumentError,"type: keyword cannot be nil")
        end
      end
    end
  end

  describe "#validate" do
    context "when given a single value" do
      let(:value) { "foo" }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end

      context "but the value is nil" do
        let(:value) { nil }

        it "must return [false, \"cannot be empty\"]" do
          expect(subject.validate(value)).to eq(
            [false, "cannot be empty"]
          )
        end

        context "when #allow_empty? is true" do
          subject { described_class.new(allow_empty: true) }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "and the value is invalid" do
        let(:value) { "" }

        it "must return the validation error from #type.validate" do
          expect(subject.validate(value)).to eq(
            [false, "contains an invalid value: does not allow an empty value"]
          )
        end
      end
    end

    context "when given multiple values" do
      let(:values) { %w[foo bar baz] }

      it "must return true" do
        expect(subject.validate(values)).to be(true)
      end

      context "but the value is []" do
        let(:value) { [] }

        it "must return [false, \"cannot be empty\"]" do
          expect(subject.validate(value)).to eq(
            [false, "cannot be empty"]
          )
        end

        context "when #allow_empty? is true" do
          subject { described_class.new(allow_empty: true) }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "but one of the values is invalid" do
        let(:values) { ["foo", nil, "bar"] }

        it "must return the validation error from #type.validate" do
          expect(subject.validate(values)).to eq(
            [false, "contains an invalid value: value cannot be nil"]
          )
        end
      end
    end
  end

  describe "#format" do
    context "when given a single value" do
      let(:value) { "foo" }

      it "must return the String version of that value" do
        expect(subject.format(value)).to eq(value.to_s)
      end
    end

    context "when given multiple values" do
      let(:values) { %w[foo bar baz] }

      it "must join the values with ','" do
        expect(subject.format(values)).to eq(values.join(','))
      end

      context "when initialized with a custom separator" do
        let(:separator) { ':' }

        subject { described_class.new(separator: separator) }

        it "must join the values with #separator" do
          expect(subject.format(values)).to eq(values.join(subject.separator))
        end
      end
    end
  end
end
