require 'spec_helper'
require 'command_mapper/types/num'

describe CommandMapper::Types::Num do
  describe "#validate" do
    context "when initialized with required: true" do
      subject { described_class.new(required: true) }

      context "and given nil value" do
        let(:value) { nil }

        it "must return [false, \"does not allow a nil value\"]" do
          expect(subject.validate(value)).to eq(
            [false, "does not allow a nil value"]
          )
        end
      end
    end

    context "when given an Integer" do
      let(:value) { 1 }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end
    end

    context "when given a String" do
      context "and it contains only digits" do
        let(:value) { "0123456789" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "and the String contains a newline" do
          let(:value) { "01234\n56789" }

          it "must return [false, \"value is not in hexadecimal format\"]" do
            expect(subject.validate(value)).to eq(
              [false, "value contains non-numeric characters"]
            )
          end
        end
      end

      context "and it contains non-digits" do
        let(:value) { "12abc34" }

        it "must return [false, \"value must be numeric\"]" do
          expect(subject.validate(value)).to eq(
            [false, "value contains non-numeric characters"]
          )
        end
      end
    end
  end
end
