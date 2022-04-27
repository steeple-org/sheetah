# frozen_string_literal: true

require "sheetah/errors/error"

RSpec.describe Sheetah::Errors::Error do
  it "is some kind of StandardError" do
    expect(described_class.superclass).to be(StandardError)
  end
end
