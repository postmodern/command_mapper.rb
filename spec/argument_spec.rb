require 'spec_helper'
require 'command_mapper/argument'
require 'command_mapper/formats/list'

describe CommandMapper::Argument do
  include CommandMapper

  describe "#initialize" do
    let(:name) { :foo }

    subject { described_class.new(name) }

    it "must set #name" do
      expect(subject.name).to eq(name)
    end

    it "must default #repeats? to false" do
      expect(subject.repeats?).to be(false)
    end

    context "when given the formta: keyword argument" do
      let(:format) { Formats::List.new(',') }

      subject { described_class.new(name, format: format) }

      it "must set #format" do
        expect(subject.format).to eq(format)
      end
    end

    context "when given the repeats: true keyword argument" do
      subject { described_class.new(name, repeats: true) }

      it "#repeats? must be true" do
        expect(subject.repeats?).to be(true)
      end
    end

    context "when given the required: false keyword argument" do
      subject { described_class.new(name, required: false) }

      it "#required? must be true" do
        expect(subject.required?).to be(false)
      end
    end

    context "when given the required: false keyword argument" do
      subject { described_class.new(name, required: false) }

      it "#required? must be false" do
        expect(subject.required?).to be(false)
      end
    end
  end
end
