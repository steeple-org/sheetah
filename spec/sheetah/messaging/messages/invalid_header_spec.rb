# frozen_string_literal: true

require "sheetah/messaging/messages/invalid_header"

RSpec.describe Sheetah::Messaging::Messages::InvalidHeader do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end

  it "may be valid" do
    msg = described_class.new(
      code: "invalid_header",
      code_data: "header_foo",
      scope: "COL",
      scope_data: { col: "FOO" },
      validatable: true
    )

    expect(msg.validate).to be_nil
  end
end
