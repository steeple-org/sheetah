# frozen_string_literal: true

require "sheetah/errors/spec_error"

RSpec.describe Sheetah::Errors::SpecError do
  it "has a msg_code" do
    expect(described_class.msg_code).to eq("sheetah.errors.spec_error")
  end
end
