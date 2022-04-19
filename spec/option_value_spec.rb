require 'spec_helper'
require 'command_mapper/option_value'
require 'command_mapper/types/num'
require 'command_mapper/types/list'

describe CommandMapper::OptionValue do
  describe "#validate" do
    let(:type) { Types::Num.new }

    subject { described_class.new(type: type) }

    context "when the option value is not required" do
      subject do
        described_class.new(type: type, required: false)
      end

      context "and given a value of true" do
        it "must return true" do
          expect(subject.validate(true)).to be(true)
        end
      end
    end

    context "otherwise" do
      it "must validate the value using #type.validate" do
        expect(subject.validate('1234')).to be(true)
        expect(subject.validate('foo')).to eq(
          [false, "contains non-numeric characters (\"foo\")"]
        )
      end
    end
  end

  describe "#format" do
    let(:type) { Types::List.new }

    subject { described_class.new(type: type) }

    let(:value) { [1,2,3] }

    it "must call the #type.format" do
      expect(subject.format(value)).to eq(type.format(value))
    end
  end
end
