require 'spec_helper'
require 'command_mapper/types/key_value'
require 'command_mapper/types/list'

describe CommandMapper::Types::KeyValue do
  describe "#initialize" do
    it "must default #separator to '='" do
      expect(subject.separator).to eq('=')
    end

    it "must initialize #key" do
      expect(subject.key).to be_kind_of(CommandMapper::Types::Value)
    end

    it "must require a 'key' value by default" do
      expect(subject.key.required?).to be(true)
    end

    it "must initialize #value" do
      expect(subject.value).to be_kind_of(CommandMapper::Types::Value)
    end

    it "must require a 'value' value by default" do
      expect(subject.value.required?).to be(true)
    end

    context "when given the separator: keyword" do
      let(:separator) { ':' }

      subject { described_class.new(separator: separator) }

      it "must set #separator" do
        expect(subject.separator).to eq(separator)
      end
    end

    context "when given the key: :optional" do
      subject { described_class.new(key: :optional) }

      it "must initialize #key" do
        expect(subject.key).to be_kind_of(CommandMapper::Types::Value)
      end

      it "must not require a 'key' value by default" do
        expect(subject.key.required?).to be(false)
      end
    end

    context "when given the value: :optional" do
      subject { described_class.new(value: :optional) }

      it "must initialize #value" do
        expect(subject.value).to be_kind_of(CommandMapper::Types::Value)
      end

      it "must not require a 'value' value by default" do
        expect(subject.value.required?).to be(false)
      end
    end

    context "when given key: nil" do
      it do
        expect {
          described_class.new(key: nil)
        }.to raise_error(ArgumentError,"key: keyword cannot be nil")
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
    context "when given a Hash" do
      let(:key)   { "foo" }
      let(:value) { "bar" }
      let(:hash)  { {key => value} }

      it "must format the hash'es key and value into a key=value pair" do
        expect(subject.format(hash)).to eq("#{key}=#{value}")
      end

      context "when initialized with a custom key: keyword argument" do
        subject { described_class.new(key: Types::List.new) }

        let(:key) { [1,2] }

        it "must format the key using #key.format" do
          expect(subject.format(hash)).to eq("#{key.join(',')}=#{value}")
        end
      end

      context "when initialized with a custom key: keyword argument" do
        subject { described_class.new(value: Types::List.new) }

        let(:value) { [1,2] }

        it "must format the value using #value.format" do
          expect(subject.format(hash)).to eq("#{key}=#{value.join(',')}")
        end
      end

      context "when initialized with a custom separator" do
        let(:separator) { ':' }

        subject { described_class.new(separator: separator) }

        it "must use the custom separator" do
          expect(subject.format(hash)).to eq("#{key}#{separator}#{value}")
        end
      end
    end

    context "when given an Array" do
      let(:key)   { "foo" }
      let(:value) { "bar" }
      let(:array) { [key, value] }

      it "must format the array's first and second elements into a key=value pair" do
        expect(subject.format(array)).to eq("#{key}=#{value}")
      end

      context "when the array has one element" do
        let(:array) { [key] }

        it "must format only that key element" do
          expect(subject.format(array)).to eq("#{key}=")
        end
      end

      context "when the array has more than two element" do
        subject { described_class.new(value: Types::List.new) }

        let(:values) { [1,2,3]        }
        let(:array)  { [key, *values] }

        it "must format the additional elements using the value type" do
          expect(subject.format(array)).to eq("#{key}=#{values.join(',')}")
        end
      end

      context "when initialized with a custom separator" do
        let(:separator) { ':' }

        subject { described_class.new(separator: separator) }

        it "must use the custom separator" do
          expect(subject.format(array)).to eq("#{key}#{separator}#{value}")
        end
      end
    end

    context "when another kind of Object is given" do
      let(:value) { 42 }

      it "must return the String version of that object" do
        expect(subject.format(value)).to eq(value.to_s)
      end
    end
  end
end
