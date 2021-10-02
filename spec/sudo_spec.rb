require 'spec_helper'
require 'command_mapper/sudo'

describe CommandMapper::Sudo do
  let(:command) { %w[ls -la /root] }

  subject { described_class.new({command: command}) }

  describe "#initialize" do
    it "must accept a command keyword" do
      expect(subject.command).to eq(command)
    end
  end

  describe "#argv" do
    it "the first argument must be 'sudo'" do
      expect(subject.argv.first).to eq('sudo')
    end

    it "must end with the command arguments" do
      expect(subject.argv[-command.length..-1]).to eq(command)
    end
  end
end
