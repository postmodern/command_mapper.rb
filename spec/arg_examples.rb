require 'rspec'

shared_examples "Arg#validate" do
  shared_examples "when a String is given" do
    context "and when a String is given" do
      let(:value) { "foo" }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end

      context "but it's empty" do
        let(:value) { "" }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq(
            [false, "does not allow an empty value"]
          )
        end

        context "but the value allows empty values" do
          let(:value_allows_empty) { true }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      context "but it's blank" do
        let(:value) { "   " }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq(
            [false, "does not allow a blank value"]
          )
        end

        context "but the value allows blank values" do
          let(:value_allows_blank) { true }

          it "must return true" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end
    end
  end

  shared_examples "when an Integer is given" do
    context "and when an Integer is given" do
      let(:value) { 3 }

      it "must return true" do
        expect(subject.validate(value)).to be(true)
      end
    end
  end

  context "when the argument requires a value" do
    let(:accepts_value)  { true }
    let(:value_required) { true }

    context "and when the argument can be repeated" do
      let(:repeats) { true }

      context "is given an Array" do
        let(:value) { ["foo"] }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "but it's empty" do
          let(:value) { [] }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "requires at least one value"]
            )
          end
        end
      end

      include_examples "when a String is given"

      context "is given nil" do
        let(:value) { nil }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq(
            [false, "requires at least one value"]
          )
        end
      end
    end

    context "but the argument can only be specified once" do
      let(:repeats) { false }

      include_examples "when a String is given"
      include_examples "when an Integer is given"

      context "and when nil is given" do
        let(:value) { nil }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to eq(
            [false, "does not allow a nil value"]
          )
        end
      end
    end
  end

  context "when the argument does not require a value" do
    let(:accepts_value)  { true  }
    let(:value_required) { false }

    context "and when the argument can be repeated" do
      let(:repeats) { true }

      context "is given an Array" do
        let(:value) { ["foo"] }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "but it's empty" do
          let(:value) { [] }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to be(true)
          end
        end
      end

      include_examples "when a String is given"
      include_examples "when an Integer is given"

      context "and when nil is given" do
        let(:value) { nil }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to be(true)
        end
      end
    end

    context "but the argument can only be specified once" do
      let(:repeats) { false }

      context "is given an Array" do
        let(:value) { ["foo"] }

        it "must return true" do
          expect(subject.validate(value)).to be(true)
        end

        context "but it's empty" do
          let(:value) { [] }

          it "must return false and a validation error message" do
            expect(subject.validate(value)).to eq(
              [false, "does not allow an empty value"]
            )
          end
        end
      end

      include_examples "when a String is given"
      include_examples "when an Integer is given"

      context "and when nil is given" do
        let(:value) { nil }

        it "must return false and a validation error message" do
          expect(subject.validate(value)).to be(true)
        end
      end
    end
  end
end
