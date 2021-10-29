require 'spec_helper'
require 'command_mapper/types/key_value'
require 'command_mapper/types/num'
require 'command_mapper/types/list'

describe CommandMapper::Types::KeyValue do
  describe "#initialize" do
    it "must default #separator to '='" do
      expect(subject.separator).to eq('=')
    end

    it "must initialize #key" do
      expect(subject.key).to be_kind_of(CommandMapper::Types::Str)
    end

    it "must require a non-empty 'key' value by default" do
      expect(subject.key.allow_empty?).to be(false)
    end

    it "must initialize #value" do
      expect(subject.value).to be_kind_of(CommandMapper::Types::Str)
    end

    it "must require a non-empty 'value' value by default" do
      expect(subject.value.allow_empty?).to be(false)
    end

    context "when given the separator: keyword" do
      let(:separator) { ':' }

      subject { described_class.new(separator: separator) }

      it "must set #separator" do
        expect(subject.separator).to eq(separator)
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

  describe "#validate" do
    context "when given a Hash" do
      context "and the Hash contains only one key:value pair" do
        let(:key)   { "foo" }
        let(:value) { "bar" }
        let(:hash)  { {key => value} }

        it "must return true" do
          expect(subject.validate(hash)).to be(true)
        end

        context "when #key is a custom Types::Type object" do
          let(:key_type) { Types::Num.new }
          let(:key) { "foo" }

          subject { described_class.new(key: key_type) }

          it "must validate the key value using #key.validate" do
            expect(subject.validate(hash)).to eq(
              [false, "key is invalid: value contains non-numeric characters"]
            )
          end
        end

        context "when #value is a custom Types::Type object" do
          let(:value_type) { Types::Num.new }
          let(:value)      { "foo"          }

          subject { described_class.new(value: value_type) }

          it "must validate the key value using #key.validate" do
            expect(subject.validate(hash)).to eq(
              [false, "value is invalid: value contains non-numeric characters"]
            )
          end
        end
      end

      context "but the Hash contains more than one pair" do
        let(:hash)  { {"foo" => "bar", "baz" => "qux"} }

        it "must return true" do
          expect(subject.validate(hash)).to eq(
            [false, "value cannot contain multiple key:value pairs"]
          )
        end
      end
    end

    context "when given an Array" do
      context "but the Array is empty" do
        let(:array) { [] }

        it "must return true" do
          expect(subject.validate(array)).to eq(
            [false, "value must contain two elements"]
          )
        end
      end

      context "and the Array contains only one elemnet" do
        let(:array) { ["foo"] }

        it "must return true" do
          expect(subject.validate(array)).to eq(
            [false, "value must contain two elements"]
          )
        end
      end

      context "and the Array contains only two elements" do
        let(:key)   { "foo" }
        let(:value) { "bar" }
        let(:array) { [key, value] }

        it "must return true" do
          expect(subject.validate(array)).to be(true)
        end

        context "when #key is a custom Types::Type object" do
          let(:key_type) { Types::Num.new }
          let(:key) { "foo" }

          subject { described_class.new(key: key_type) }

          it "must validate the key value using #key.validate" do
            expect(subject.validate(array)).to eq(
              [false, "key is invalid: value contains non-numeric characters"]
            )
          end
        end

        context "when #value is a custom Types::Type object" do
          let(:value_type) { Types::Num.new }
          let(:value)      { "foo"          }

          subject { described_class.new(value: value_type) }

          it "must validate the key value using #key.validate" do
            expect(subject.validate(array)).to eq(
              [false, "value is invalid: value contains non-numeric characters"]
            )
          end
        end
      end

      context "but the Array contains more than two elements" do
        let(:array) { ["foo", "bar", "baz"] }

        it "must return true" do
          expect(subject.validate(array)).to eq(
            [false, "value cannot contain more than two elements"]
          )
        end
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
        subject { described_class.new(key: Types::Num.new) }

        let(:key) { 42 }

        it "must format the key using #key.format" do
          expect(subject.format(hash)).to eq("#{key}=#{value}")
        end
      end

      context "when initialized with a custom key: keyword argument" do
        subject { described_class.new(value: Types::List.new) }

        let(:value) { %w[bar baz] }

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

      context "when initialized with a custom key: keyword argument" do
        subject { described_class.new(key: Types::Num.new) }

        let(:key) { 42 }

        it "must format the key using #key.format" do
          expect(subject.format(array)).to eq("#{key}=#{value}")
        end
      end

      context "when initialized with a custom key: keyword argument" do
        subject { described_class.new(value: Types::List.new) }

        let(:value) { %w[bar baz] }

        it "must format the value using #value.format" do
          expect(subject.format(array)).to eq("#{key}=#{value.join(',')}")
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
