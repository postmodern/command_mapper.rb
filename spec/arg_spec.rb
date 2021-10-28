require 'spec_helper'
require 'arg_examples'
require 'command_mapper/arg'
require 'command_mapper/types/list'

describe CommandMapper::Arg do
  include CommandMapper

  describe "#initialize" do
    it "must default #repeats? to false" do
      expect(subject.repeats?).to be(false)
    end

    context "when given the repeats: true keyword argument" do
      subject { described_class.new(repeats: true) }

      it "#repeats? must be true" do
        expect(subject.repeats?).to be(true)
      end
    end

    context "when given the value: keyword argument" do
      context "and it's a custom Types::Type class" do
        let(:value) { Types::List.new(separator: ',') }

        subject { described_class.new(value: value) }

        it "must set #value" do
          expect(subject.value).to eq(value)
        end
      end

      context "when given a Hash" do
        context "when given the required: false keyword argument" do
          subject { described_class.new(value: {required: false}) }

          it "value's #required? must be true" do
            expect(subject.value.required?).to be(false)
          end
        end

        context "when given the required: false keyword argument" do
          subject { described_class.new(value: {required: false}) }

          it "the value's #required? must be false" do
            expect(subject.value.required?).to be(false)
          end
        end
      end
    end
  end

  let(:repeats) { false }
  let(:accepts_value) { false }
  let(:value_required) { false }
  let(:value_allows_empty) { false }
  let(:value_allows_blank) { false }

  subject do
    described_class.new(
      value: {
        required:    value_required,
        allow_empty: value_allows_empty,
        allow_blank: value_allows_blank
      },
      repeats: repeats
    )
  end

  describe "#validate" do
    include_examples "Arg#validate"
  end
end
