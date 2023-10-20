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

  describe "#to_h" do
    it "returns the attributes as a hash" do
      attrs = {
        code: double,
        code_data: double,
        scope: double,
        scope_data: double,
        severity: double,
      }

      message = described_class.new(**attrs)

      expect(message.to_h).to eq(attrs)
    end
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

  describe "validations" do
    it "is valid by default" do
      msg = described_class.new(code: double, validatable: true)

      expect(msg.validate).to be_nil
    end

    context "when customized" do
      let(:msg_class) do
        Class.new(described_class) do
          def self.code
            "foobar"
          end

          validate_with do
            row

            def validate_code_data(message)
              message.code_data.is_a?(Hash)
            end
          end
        end
      end

      let(:msg) do
        msg_class.new(
          code: "foobar",
          code_data: {},
          scope: "ROW",
          scope_data: { row: 42 },
          validatable: true
        )
      end

      it "may be valid" do
        expect(msg.validate).to be_nil
      end

      it "validates the code" do
        msg.code = "qoifo"

        expect { msg.validate }.to raise_error(
          Sheetah::Messaging::MessageValidations::InvalidMessage,
          /^code /
        )
      end

      it "validates the code data" do
        msg.code_data = nil

        expect { msg.validate }.to raise_error(
          Sheetah::Messaging::MessageValidations::InvalidMessage,
          /^code_data /
        )
      end

      it "validates the scope" do
        msg.scope = "SHEET"

        expect { msg.validate }.to raise_error(
          Sheetah::Messaging::MessageValidations::InvalidMessage,
          /^scope /
        )
      end

      it "validates the scope_data" do
        msg.scope_data = nil

        expect { msg.validate }.to raise_error(
          Sheetah::Messaging::MessageValidations::InvalidMessage,
          /^scope_data /
        )
      end

      it "validates multiple attributes at once" do
        msg.code_data = nil
        msg.scope_data = nil

        expect { msg.validate }.to raise_error(
          Sheetah::Messaging::MessageValidations::InvalidMessage,
          /^code_data, scope_data /
        )
      end

      it "may ignore validations" do
        msg = msg_class.new(validatable: false)

        expect(msg.validate).to be_nil
      end

      describe "inheritance" do
        let(:msg1_class) do
          Class.new(msg_class) do
            def self.code
              "barbaz"
            end
          end
        end

        let(:msg1) do
          msg1_class.new(
            code: "barbaz",
            code_data: {},
            scope: "ROW",
            scope_data: { row: 42 },
            validatable: true
          )
        end

        it "may rely on a parent validator" do
          expect(msg1.validate).to be_nil

          msg1.scope = "SHEET"

          expect { msg1.validate }.to raise_error(
            Sheetah::Messaging::MessageValidations::InvalidMessage,
            /^scope /
          )
        end
      end
    end
  end

  describe "initializations" do
    before do
      allow(described_class).to receive(:validate)
    end

    describe "::new" do
      it "will not validate after initialization" do
        described_class.new(code: double, validatable: true)
        expect(described_class).not_to have_received(:validate)
      end
    end

    describe "::new!" do
      it "will validate after initialization" do
        message = described_class.new!(code: double, validatable: true)
        expect(described_class).to have_received(:validate).with(message)
      end
    end
  end
end
