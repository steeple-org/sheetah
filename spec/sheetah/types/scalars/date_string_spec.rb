# frozen_string_literal: true

require "sheetah/types/scalars/date_string"
require "support/shared/scalar_type"

RSpec.describe Sheetah::Types::Scalars::DateString do
  subject do
    described_class.new(date_fmt: "foobar")
  end

  include_examples "scalar_type"

  it "inherits from the basic scalar type" do
    expect(described_class.superclass).to be(Sheetah::Types::Scalars::Scalar)
  end

  describe "::cast_classes" do
    it "extends the superclass' ones" do
      expect(described_class.cast_classes).to eq(
        described_class.superclass.cast_classes + [Sheetah::Types::Scalars::DateStringCast]
      )
    end
  end
end
