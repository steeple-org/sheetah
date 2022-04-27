# frozen_string_literal: true

require "sheetah/row_processor"
require "sheetah/sheet"

RSpec.describe Sheetah::RowProcessor do
  let(:headers) do
    instance_double(Enumerable)
  end

  let(:row) do
    instance_double(Sheetah::Sheet::Row, value: double)
  end

  let(:processed_row) do
    double
  end

  let(:processor) do
    described_class.new(headers: headers)
  end

  before do
    allow(headers).to receive(:zip).with(row.value).and_return(processed_row)
  end

  it "processes the row" do
    expect(processor.call(row)).to eq(processed_row)
  end
end
