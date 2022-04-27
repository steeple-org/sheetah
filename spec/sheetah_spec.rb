# frozen_string_literal: true

require "sheetah/column"
require "sheetah/sheet_processor"
require "sheetah/specification"
require "sheetah/backends/wrapper"

require "sheetah/types/composites/array"
require "sheetah/types/scalars/scalar"
require "sheetah/types/scalars/string"
require "sheetah/types/scalars/email"

RSpec.describe Sheetah, monadic_result: true do
  let(:columns) do
    foo_type = Sheetah::Types::Scalars::String.new

    bar_type = Sheetah::Types::Composites::Array.new(
      [
        Sheetah::Types::Scalars::String.new,
        Sheetah::Types::Scalars::Scalar.new,
        Sheetah::Types::Scalars::Email.new,
        Sheetah::Types::Scalars::Scalar.new,
        Sheetah::Types::Scalars::Scalar.new,
      ]
    )

    [
      Sheetah::Column.new(
        key: :foo,
        type: foo_type,
        index: nil,
        header: "Foo",
        header_pattern: /^foo$/i
      ),
      Sheetah::Column.new(
        key: :bar,
        type: bar_type,
        index: 0,
        header: "Bar 1",
        header_pattern: /^bar 1$/i
      ),
      Sheetah::Column.new(
        key: :bar,
        type: bar_type,
        index: 1,
        header: "Bar 2",
        header_pattern: /^bar 2$/i
      ),
      Sheetah::Column.new(
        key: :bar,
        type: bar_type,
        index: 2,
        header: "Bar 3",
        header_pattern: /^bar 3$/i
      ),
      Sheetah::Column.new(
        key: :bar,
        type: bar_type,
        index: 3,
        header: "Bar 4",
        header_pattern: /^bar 4$/i
      ),
      Sheetah::Column.new(
        key: :bar,
        type: bar_type,
        index: 4,
        header: "Bar 5",
        header_pattern: /^bar 5$/i
      ),
    ]
  end

  let(:specification) do
    Sheetah::Specification.new
  end

  let(:processor) do
    Sheetah::SheetProcessor.new(specification)
  end

  let(:input) do
    [
      ["foo", "bar 3", "bar 5", "bar 1"],
      ["hello", "foo@bar.baz", Float, nil],
      ["world", "foo@bar.baz", Float, nil],
      ["world", "boudiou !", Float, nil],
    ]
  end

  def process(*args, **opts, &block)
    processor.call(*args, backend: Sheetah::Backends::Wrapper, **opts, &block)
  end

  def process_to_a(*args, **opts)
    a = []
    processor.call(*args, backend: Sheetah::Backends::Wrapper, **opts) { |result| a << result }
    a
  end

  before do
    columns.each do |column|
      specification.set(column.header_pattern, column)
    end
  end

  context "when there is no sheet error" do
    it "is a success without errors" do
      result = process(input) {}

      expect(result).to have_attributes(result: Success(), messages: [])
    end

    it "yields a commented result for each valid and invalid row" do
      results = process_to_a(input)

      expect(results).to have_attributes(size: 3)
      expect(results[0]).to have_attributes(result: be_success, messages: be_empty)
      expect(results[1]).to have_attributes(result: be_success, messages: be_empty)
      expect(results[2]).to have_attributes(result: be_failure, messages: have_attributes(size: 1))
    end

    it "yields the successful value for each valid row" do
      results = process_to_a(input)

      expect(results[0].result).to eq(
        Success(foo: "hello", bar: [nil, nil, "foo@bar.baz", nil, Float])
      )

      expect(results[1].result).to eq(
        Success(foo: "world", bar: [nil, nil, "foo@bar.baz", nil, Float])
      )
    end

    it "yields the failure data for each invalid row" do
      results = process_to_a(input)

      expect(results[2].result).to eq(Failure())
      expect(results[2].messages).to contain_exactly(
        have_attributes(
          code: "must_be_email",
          code_data: { value: "boudiou !".inspect },
          scope: Sheetah::Messaging::SCOPES::CELL,
          scope_data: { row: 3, col: "B" },
          severity: Sheetah::Messaging::SEVERITIES::ERROR
        )
      )
    end
  end

  context "when there is a sheet error" do
    before do
      input[0][2] = nil
    end

    it "doesn't yield any row" do
      expect { |b| process(input, &b) }.not_to yield_control
    end

    it "returns a failure with data" do
      expect(process(input) {}).to have_attributes(
        result: Failure(),
        messages: [
          have_attributes(
            code: "invalid_header",
            code_data: nil,
            scope: Sheetah::Messaging::SCOPES::COL,
            scope_data: { col: "C" },
            severity: Sheetah::Messaging::SEVERITIES::ERROR
          ),
        ]
      )
    end
  end
end
