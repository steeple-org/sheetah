# frozen_string_literal: true

require "sheetah/messaging"
require "sheetah/headers"
require "sheetah/row_processor"
require "sheetah/sheet"

RSpec.describe Sheetah::RowProcessor, monadic_result: true do
  let(:messenger) do
    instance_double(Sheetah::Messaging::Messenger, dup: row_messenger)
  end

  let(:row_messenger) do
    Sheetah::Messaging::Messenger.new
  end

  let(:headers) do
    [
      instance_double(Sheetah::Headers::Header, column: double, row_value_index: 0),
      instance_double(Sheetah::Headers::Header, column: double, row_value_index: 1),
      instance_double(Sheetah::Headers::Header, column: double, row_value_index: 2),
    ]
  end

  let(:cells) do
    [
      instance_double(Sheetah::Sheet::Cell, value: double, col: double),
      instance_double(Sheetah::Sheet::Cell, value: double, col: double),
      instance_double(Sheetah::Sheet::Cell, value: double, col: double),
    ]
  end

  let(:row) do
    instance_double(Sheetah::Sheet::Row, row: double, value: cells)
  end

  let(:row_value_builder) do
    instance_double(Sheetah::RowValueBuilder)
  end

  let(:row_value_builder_result) do
    double
  end

  let(:processor) do
    described_class.new(headers: headers, messenger: messenger)
  end

  def expect_headers_add(header, cell)
    expect(row_value_builder).to receive(:add).with(header.column, cell.value).ordered do
      expect(row_messenger).to have_attributes(
        scope: Sheetah::Messaging::SCOPES::CELL,
        scope_data: { row: row.row, col: cell.col }
      )
    end
  end

  def expect_headers_result
    expect(row_value_builder).to receive(:result).ordered.and_return(row_value_builder_result)
  end

  before do
    allow(Sheetah::RowValueBuilder).to(
      receive(:new).with(row_messenger).and_return(row_value_builder)
    )
  end

  it "processes the row and wraps the result with a dedicated set of messages" do
    expect_headers_add(headers[0], cells[0])
    expect_headers_add(headers[1], cells[1])
    expect_headers_add(headers[2], cells[2])
    expect_headers_result

    expect(processor.call(row)).to eq(
      Sheetah::RowProcessorResult.new(
        row: row.row,
        result: row_value_builder_result,
        messages: row_messenger.messages
      )
    )
  end
end
