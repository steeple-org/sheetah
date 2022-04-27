# frozen_string_literal: true

require "sheetah/types/composites/composite"
require "support/shared/composite_type"

RSpec.describe Sheetah::Types::Composites::Composite do
  include_examples "composite_type"

  it "inherits from the basic type" do
    expect(described_class.superclass).to be(Sheetah::Types::Type)
  end

  describe "::cast_classes" do
    it "is empty" do
      expect(described_class.cast_classes).to be_empty
    end
  end
end
