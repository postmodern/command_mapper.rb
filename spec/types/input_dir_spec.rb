require 'spec_helper'
require 'command_mapper/types/input_dir'

describe CommandMapper::Types::InputDir do
  describe "#validate" do
    context "when given a valid directory path" do
      let(:value) { __dir__ }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end
    end

    context "when given a valid file path" do
      let(:value) { __FILE__ }

      it "must return [false, 'directory does not exist (...)']" do
        expect(subject.validate(value)).to eq(
          [false, "directory does not exist (#{value.inspect})"]
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
