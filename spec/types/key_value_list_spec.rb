require 'spec_helper'
require 'command_mapper/types/key_value_list'

describe CommandMapper::Types::KeyValueList do
  describe "#initialize" do
    it "must default #separator to ','" do
      expect(subject.separator).to eq(',')
    end

    it "must initialize #value to a Types::KeyValue object" do
      expect(subject.value).to be_kind_of(Types::KeyValue)
    end

    it "must default #value.separator to '='" do
      expect(subject.value.separator).to eq('=')
    end

    context "when given the separator: keyword" do
      let(:separator) { ';' }

      subject { described_class.new(separator: separator) }

      it "must set #separator" do
        expect(subject.separator).to eq(separator)
      end
    end

    context "when given the key_value_separator: keyword" do
      let(:separator) { ':' }

      subject { described_class.new(key_value_separator: separator) }

      it "must set #key_value.separator" do
        expect(subject.key_value.separator).to eq(separator)
      end
    end
  end

  describe "#format" do
    context "when given an Array" do
      context "containing a single key:value pair" do
        let(:key)   { "foo" }
        let(:value) { 42    }

        let(:array) { [[key, value]] }

        it "must join the key and value with #key_value_separator" do
          expect(subject.format(array)).to eq(
            "#{key}#{subject.key_value.separator}#{value}"
          )
        end
      end

      context "when given multiple key:value pairs" do
        let(:key1)   { "foo" }
        let(:value1) { 42    }
        let(:key2)   { "bar" }
        let(:value2) { 100   }

        let(:array) { [[key1, value1], [key2, value2]] }

        it "must join the keys and values with #key_value.separator, and then with #separator" do
          expect(subject.format(array)).to eq(
            "#{key1}#{subject.key_value.separator}#{value1}#{subject.separator}#{key2}#{subject.key_value.separator}#{value2}"
          )
        end
      end
    end

    context "when given an Hash" do
      context "containing a single key:value pair" do
        let(:key)   { "foo" }
        let(:value) { 42    }

        let(:hash) { {key => value} }

        it "must join the key and value with #key_value_separator" do
          expect(subject.format(hash)).to eq(
            "#{key}#{subject.key_value.separator}#{value}"
          )
        end
      end

      context "containing multiple key:value pairs" do
        let(:key1)   { "foo" }
        let(:value1) { 42    }
        let(:key2)   { "bar" }
        let(:value2) { 100   }

        let(:hash) { {key1 => value1, key2 => value2} }

        it "must join the keys and values with #key_value.separator, and then with #separator" do
          expect(subject.format(hash)).to eq(
            "#{key1}#{subject.key_value.separator}#{value1}#{subject.separator}#{key2}#{subject.key_value.separator}#{value2}"
          )
        end
      end
    end
  end
end
