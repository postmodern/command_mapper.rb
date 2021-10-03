require 'spec_helper'
require 'command_mapper/types/input_file'

describe CommandMapper::Types::InputFile do
  describe "#validate" do
    context "when given a valid file path" do
      let(:path) { __FILE__ }

      it "must return true" do
        expect(subject.validate(path)).to be(true)
      end
    end

    context "when given a valid directory path" do
      let(:path) { __dir__ }

      it "must return [false, 'file does not exist']" do
        expect(subject.validate(path)).to eq([false, "file does not exist"])
      end
    end

    context "when given a path that does not exist" do
      let(:path) { "/path/does/not/exist" }

      it "must return [false, 'path does not exist']" do
        expect(subject.validate(path)).to eq([false, "path does not exist"])
      end
    end
  end
end
