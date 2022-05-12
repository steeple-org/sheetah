# frozen_string_literal: true

require "sheetah/sheet_processor_result"

RSpec.describe Sheetah::SheetProcessorResult do
  let(:result) { double }
  let(:messages) { double }

  it "wraps a result with messages" do
    processor_result = described_class.new(result: result, messages: messages)
    expect(processor_result).to have_attributes(result: result, messages: messages)
  end

  it "is equivalent to a similar result with similar messages" do
    processor_result0 = described_class.new(result: result, messages: messages)
    processor_result1 = described_class.new(result: result, messages: messages)
    expect(processor_result0).to eq(processor_result1)
  end

  it "may wrap a result with implicit messages" do
    processor_result = described_class.new(result: result)
    expect(processor_result).to have_attributes(result: result, messages: [])
  end
end
