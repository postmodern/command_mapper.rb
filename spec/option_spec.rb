require 'spec_helper'
require 'command_mapper/option'

describe CommandMapper::Option do
  describe "#initialize" do
    let(:flag) { '--foo' }

    subject { described_class.new(flag) }

    it "must set #flag" do
      expect(subject.flag).to eq(flag)
    end

    it "must default #repeats? to false" do
      expect(subject.repeats?).to be(false)
    end

    context "when equals: true is given" do
      subject { described_class.new(flag, equals: true) }

      it "#equals? must return true" do
        expect(subject.equals?).to be(true)
      end
    end

    context "when given the repeats: true keyword argument" do
      subject { described_class.new(flag, repeats: true) }

      it "#repeats? must be true" do
        expect(subject.repeats?).to be(true)
      end
    end

    context "when value: is given" do
      let(:value_options) { {required: true} }

      subject { described_class.new(flag, value: value_options) }

      it "must initialize #value with the value: options" do
        expect(subject.value).to be_kind_of(OptionValue)
      end
    end
  end

  describe ".infer_name_from_flag" do
    subject { described_class.infer_name_from_flag(flag) }

    context "when given a long flag" do
      let(:name) { "foo"       }
      let(:flag) { "--#{name}" }

      it "must return the flag name as a Symbol" do
        expect(subject).to eq(name.to_sym)
      end

      context "when the flag contains a '-'" do
        let(:flag) { '--foo-bar' }

        it "must convert all '-' characters to '_'" do
          expect(subject).to eq(:foo_bar)
        end
      end

      context "when the flag contains multiple '-'" do
        let(:flag) { '--foo--bar' }

        it "must replace multiple '-' characters with a single '_'" do
          expect(subject).to eq(:foo_bar)
        end
      end

      context "when the flag contains multiple '_'" do
        let(:flag) { '--foo__bar' }

        it "must replace multiple '_' characters with a single '_'" do
          expect(subject).to eq(:foo_bar)
        end
      end
    end

    context "when given a short flag" do
      context "when the flag length is 1" do
        let(:flag) { '-x' }

        it "must raise an ArgumentError" do
          expect {
            described_class.infer_name_from_flag(flag)
          }.to raise_error(ArgumentError,"cannot infer a name from short option flag: #{flag.inspect}")
        end
      end

      context "when the flag length is 2" do
        let(:flag) { '-ip' }

        it "must return the flag name without the '-'" do
          expect(subject).to eq(:ip)
        end
      end

      context "when the flag contains uppercase characters" do
        let(:flag) { '-Ip' }

        it "must convert all uppercase characters to lowercase" do
          expect(subject).to eq(:ip)
        end
      end

      context "when the flag length is > 2" do
        context "when the flag contains a '-'" do
          let(:flag) { '-foo-bar' }

          it "must convert all '-' characters to '_'" do
            expect(subject).to eq(:foo_bar)
          end
        end

        context "when the flag contains multiple '-'" do
          let(:flag) { '-foo--bar' }

          it "must replace multiple '-' characters with a single '_'" do
            expect(subject).to eq(:foo_bar)
          end
        end

        context "when the flag contains multiple '_'" do
          let(:flag) { '-foo__bar' }

          it "must replace multiple '_' characters with a single '_'" do
            expect(subject).to eq(:foo_bar)
          end
        end
      end
    end
  end
end
