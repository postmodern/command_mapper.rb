require 'spec_helper'
require 'command_mapper/types/list'

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

    context "when given value: nil" do
      it do
        expect {
          described_class.new(value: nil)
        }.to raise_error(ArgumentError,"value: keyword cannot be nil")
      end
    end
  end

  describe "#format" do
    context "when given one value" do
      let(:value) { 42 }

      it "must return the String version of that value" do
        expect(subject.format(value)).to eq(value.to_s)
      end
    end

    context "when given multiple values" do
      let(:values) { [1,2,3] }

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
