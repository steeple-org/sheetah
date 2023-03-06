# frozen_string_literal: true

require "sheetah/messaging/messages/missing_column"

RSpec.describe Sheetah::Messaging::Messages::MissingColumn do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end

  it "may be valid" do
    msg = described_class.new(
      code: "missing_column",
      code_data: "header_foo",
      scope: "SHEET",
      scope_data: nil,
      validatable: true
    )

    expect(msg.validate).to be_nil
  end
end
