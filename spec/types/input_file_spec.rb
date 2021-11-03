require 'spec_helper'
require 'command_mapper/types/input_file'

describe CommandMapper::Types::InputFile do
  describe "#validate" do
    context "when given a valid file path" do
      let(:value) { __FILE__ }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end
    end

    context "when given a valid directory path" do
      let(:value) { __dir__ }

      it "must return [false, 'file does not exist (...)']" do
        expect(subject.validate(value)).to eq(
          [false, "file does not exist (#{value.inspect})"]
        )
      end
    end

    context "when given a path that does not exist" do
      let(:value) { "/path/does/not/exist" }

      it "must return [false, 'path does not exist (...)']" do
        expect(subject.validate(value)).to eq(
          [false, "path does not exist (#{value.inspect})"]
        )
      end
    end
  end
end
