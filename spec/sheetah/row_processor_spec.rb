# frozen_string_literal: true

require "sheetah/messaging"
require "sheetah/processor_result"
require "sheetah/row_processor"
require "sheetah/sheet"

RSpec.describe Sheetah::RowProcessor, monadic_result: true do
  let(:headers) do
    instance_double(Enumerable)
  end

  let(:messenger) do
    instance_double(Sheetah::Messaging::Messenger)
  end

  let(:messenger_dup) do
    instance_double(Sheetah::Messaging::Messenger, messages: double)
  end

  let(:row) do
    instance_double(Sheetah::Sheet::Row, row: double, value: double)
  end

  let(:processed_row) do
    double
  end

  let(:processor) do
    described_class.new(headers: headers, messenger: messenger)
  end

  before do
    allow(headers).to receive(:zip).with(row.value).and_return(processed_row)
    allow(messenger).to receive(:dup).with(no_args).and_return(messenger_dup)
  end

  it "processes the row and wraps the result with a dedicated set of messages" do
    expect(processor.call(row)).to eq(
      Sheetah::ProcessorResult.new(
        result: Success(processed_row),
        messages: messenger_dup.messages
      )
    )
  end
end
