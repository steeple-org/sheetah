# frozen_string_literal: true

require "sheetah/row_processor_result"

RSpec.describe Sheetah::RowProcessorResult do
  let(:row) { double }
  let(:result) { double }
  let(:messages) { double }

  it "wraps a result with messages" do
    processor_result = described_class.new(row:, result:, messages:)
    expect(processor_result).to have_attributes(row:, result:, messages:)
  end

  it "is equivalent to a similar result with similar messages" do
    processor_result0 = described_class.new(row:, result:, messages:)
    processor_result1 = described_class.new(row:, result:, messages:)
    expect(processor_result0).to eq(processor_result1)
  end

  it "is different from a similar result with a different row" do
    processor_result0 = described_class.new(row:, result:, messages:)
    processor_result1 = described_class.new(row: double, result:, messages:)
    expect(processor_result0).not_to eq(processor_result1)
  end

  it "may wrap a result with implicit messages" do
    processor_result = described_class.new(row:, result:)
    expect(processor_result).to have_attributes(row:, result:, messages: [])
  end
end
