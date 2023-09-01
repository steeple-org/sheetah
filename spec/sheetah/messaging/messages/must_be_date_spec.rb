# frozen_string_literal: true

require "sheetah/messaging/messages/must_be_date"

RSpec.describe Sheetah::Messaging::Messages::MustBeDate do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end

  it "may be valid" do
    msg = described_class.new(
      code: "must_be_date",
      code_data: { format: "foo" },
      scope: "CELL",
      scope_data: { col: "FOO", row: 42 },
      validatable: true
    )

    expect(msg.validate).to be_nil
  end
end