# frozen_string_literal: true

require "sheetah/types/composites/array_compact"
require "support/shared/composite_type"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Composites::ArrayCompact do
  include_examples "composite_type"

  it "inherits from the composite array type" do
    expect(described_class.superclass).to be(Sheetah::Types::Composites::Array)
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
      it "compacts the given value" do
        allow(value).to receive(:compact).and_return(compact_value = double)
        expect(cast.call(value, messenger)).to eq(compact_value)
      end
    end
  end
end
