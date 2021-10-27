require 'spec_helper'
require 'command_mapper/types/num'

describe CommandMapper::Types::Num do
  describe "#initialize" do
    it "must set #allow_blank? to false" do
      expect(subject.allow_blank?).to be(false)
    end
  end

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

    context "when initialized with allow_empty: false" do
      subject { described_class.new(allow_empty: false) }

      context "and given an empty String" do
        let(:value) { "" }

        it "must return [false, \"does not allow an empty value\"]" do
          expect(subject.validate(value)).to eq(
            [false, "does not allow an empty value"]
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
        let(:value) { "1234" }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end
      end

      context "and it contains non-digits" do
        let(:value) { "12abc34" }

        it "must return [false, \"value must be numeric\"]" do
          expect(subject.validate(value)).to eq(
            [false, "value must be numeric"]
          )
        end
      end
    end
  end
end