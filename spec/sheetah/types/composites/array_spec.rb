# frozen_string_literal: true

require "sheetah/types/composites/array"
require "support/shared/composite_type"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Composites::Array do
  include_examples "composite_type"

  it "inherits from the basic composite type" do
    expect(described_class.superclass).to be(Sheetah::Types::Composites::Composite)
  end

  describe "custom cast class" do
    subject(:cast_class) do
      described_class.cast_classes.last
    end

    it "is appended to the superclass' cast classes" do
      expect(described_class.cast_classes).to eq(
        described_class.superclass.cast_classes + [cast_class]
      )
    end

    include_examples "cast_class"

    describe "#call" do
      before do
        allow(value).to receive(:is_a?).with(Array).and_return(value_is_array)
      end

      context "when the value is an array" do
        let(:value_is_array) { true }

        it "is a success" do
          expect(cast.call(value, messenger)).to eq(value)
        end
      end

      context "when the value is not an array" do
        let(:value_is_array) { false }

        it "is a failure" do
          expect { cast.call(value, messenger) }.to throw_symbol(:failure, "must_be_array")
        end
      end
    end
  end
end
