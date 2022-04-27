# frozen_string_literal: true

require "sheetah/types/scalars/scalar"
require "support/shared/scalar_type"

RSpec.describe Sheetah::Types::Scalars::Scalar do
  include_examples "scalar_type"

  it "inherits from the basic type" do
    expect(described_class.superclass).to be(Sheetah::Types::Type)
  end

  describe "::cast_classes" do
    it "includes a basic cast class" do
      expect(described_class.cast_classes).to eq(
        [Sheetah::Types::Scalars::ScalarCast]
      )
    end
  end
end
