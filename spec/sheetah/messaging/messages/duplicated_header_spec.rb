# frozen_string_literal: true

require "sheetah/messaging/messages/duplicated_header"

RSpec.describe Sheetah::Messaging::Messages::DuplicatedHeader do
  it "has a default code" do
    expect(described_class.new).to have_attributes(code: described_class::CODE)
  end

  it "may be valid" do
    msg = described_class.new(
      code: "duplicated_header",
      code_data: { value: "header_foo" },
      scope: "COL",
      scope_data: { col: "FOO" },
      validatable: true
    )

    expect(msg.validate).to be_nil
  end
end
