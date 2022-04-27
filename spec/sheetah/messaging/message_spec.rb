# frozen_string_literal: true

require "sheetah/messaging"

RSpec.describe Sheetah::Messaging::Message do
  let(:code)       { double }
  let(:code_data)  { double }
  let(:scope)      { double }
  let(:scope_data) { double }
  let(:severity)   { double }

  let(:message) do
    described_class.new(
      code: code,
      code_data: code_data,
      scope: scope,
      scope_data: scope_data,
      severity: severity
    )
  end

  it "needs at least a code" do
    expect { described_class.new }.to raise_error(ArgumentError, /missing keyword: :code/i)
  end

  it "may have only a custom code and some defaults attributes" do
    expect(described_class.new(code: code)).to have_attributes(
      code: code,
      code_data: nil,
      scope: Sheetah::Messaging::SCOPES::SHEET,
      scope_data: nil,
      severity: Sheetah::Messaging::SEVERITIES::WARN
    )
  end

  it "may have completely custom attributes" do
    expect(message).to have_attributes(
      code: code,
      code_data: code_data,
      scope: scope,
      scope_data: scope_data,
      severity: severity
    )
  end

  it "is equivalent to a message having the same attributes" do
    other_message = described_class.new(
      code: code,
      code_data: code_data,
      scope: scope,
      scope_data: scope_data,
      severity: severity
    )
    expect(message).to eq(other_message)
  end

  it "is not equivalent to a message having different attributes" do
    other_message = described_class.new(
      code: code,
      code_data: code_data,
      scope: scope,
      scope_data: double,
      severity: severity
    )
    expect(message).not_to eq(other_message)
  end
end
