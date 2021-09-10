require 'spec_helper'
require 'command_mapper/value'

describe CommandMapper::Value do
  describe ".is_nil?" do
    context "when given nil" do
      let(:value) { nil }

      it "must return true" do
        expect(subject.is_nil?(value)).to be(true)
      end
    end

    context "when given a non-nil object" do
      let(:value) { Object.new }

      it "must return false" do
        expect(subject.is_nil?(value)).to be(false)
      end
    end
  end

  describe ".is_empty?" do
    context "and it responds_to #empty?" do
      context "and it returns true" do
        let(:value) { double('value', empty?: true) }

        it "must return true" do
          expect(subject.is_empty?(value)).to be(true)
        end
      end

      context "and it returns false" do
        let(:value) { double('value', empty?: false) }

        it "must return false" do
          expect(subject.is_empty?(value)).to be(false)
        end
      end
    end

    context "but it does not respond_to #empty?" do
      it "must return false" do
        expect(subject.is_empty?(Object.new)).to be(false)
      end
    end

    context "when given nil" do
      it "must return true" do
        expect(subject.is_empty?(nil)).to be(true)
      end
    end

    context "when given ''" do
      it "must return true" do
        expect(subject.is_empty?("")).to be(true)
      end
    end

    context "when given []" do
      it "must return true" do
        expect(subject.is_empty?([])).to be(true)
      end
    end

    context "when given {}" do
      it "must return true" do
        expect(subject.is_empty?({})).to be(true)
      end
    end
  end

  describe ".is_boolean?" do
    context "when given true" do
      it "must return true" do
        expect(subject.is_boolean?(true)).to be(true)
      end
    end

    context "when given false" do
      it "must return true" do
        expect(subject.is_boolean?(false)).to be(true)
      end
    end

    context "when given nil" do
      it "must return true" do
        expect(subject.is_boolean?(nil)).to be(true)
      end
    end

    context "when given an other Object" do
      it "must return false" do
        expect(subject.is_boolean?(Object.new)).to be(false)
      end
    end
  end
end
