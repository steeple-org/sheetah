# frozen_string_literal: true

require "sheetah/errors/type_error"

RSpec.describe Sheetah::Errors::TypeError do
  it "is some kind of Error" do
    expect(described_class).to have_attributes(superclass: Sheetah::Errors::Error)
  end
end
