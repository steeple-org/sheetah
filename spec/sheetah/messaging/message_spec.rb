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

  describe "#to_s" do
    let(:code)       { "foo_is_bar" }
    let(:code_data)  { nil }
    let(:severity)   { "ERROR" }

    context "when scoped to the sheet" do
      let(:scope)      { Sheetah::Messaging::SCOPES::SHEET }
      let(:scope_data) { nil }

      it "can be reduced to a string" do
        expect(message.to_s).to eq("[SHEET] ERROR: foo_is_bar")
      end
    end

    context "when scoped to a row" do
      let(:scope)      { Sheetah::Messaging::SCOPES::ROW }
      let(:scope_data) { { row: 42 } }

      it "can be reduced to a string" do
        expect(message.to_s).to eq("[ROW: 42] ERROR: foo_is_bar")
      end
    end

    context "when scoped to a col" do
      let(:scope)      { Sheetah::Messaging::SCOPES::COL }
      let(:scope_data) { { col: "AA" } }

      it "can be reduced to a string" do
        expect(message.to_s).to eq("[COL: AA] ERROR: foo_is_bar")
      end
    end

    context "when scoped to a cell" do
      let(:scope)      { Sheetah::Messaging::SCOPES::CELL }
      let(:scope_data) { { row: 42, col: "AA" } }

      it "can be reduced to a string" do
        expect(message.to_s).to eq("[CELL: AA42] ERROR: foo_is_bar")
      end
    end

    context "when the scope doesn't make sense" do
      let(:scope) { "oiqjzfoi" }

      it "can be reduced to a string" do
        expect(message.to_s).to eq("ERROR: foo_is_bar")
      end
    end

    context "when there is some data associated with the code" do
      let(:scope)      { Sheetah::Messaging::SCOPES::SHEET }
      let(:scope_data) { nil }
      let(:code_data) { { foo: "bar" } }

      it "can be reduced to a string" do
        expect(message.to_s).to eq("[SHEET] ERROR: foo_is_bar {:foo=>\"bar\"}")
      end
    end
  end
end
