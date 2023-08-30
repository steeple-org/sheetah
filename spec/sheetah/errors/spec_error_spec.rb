# frozen_string_literal: true

require "sheetah/errors/spec_error"

RSpec.describe Sheetah::Errors::SpecError do
  it "is some kind of Error" do
    expect(described_class).to have_attributes(superclass: Sheetah::Errors::Error)
  end
end
