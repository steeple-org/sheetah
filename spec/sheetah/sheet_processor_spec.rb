# frozen_string_literal: true

require "sheetah/sheet_processor"
require "sheetah/specification"

RSpec.describe Sheetah::SheetProcessor, monadic_result: true do
  let(:specification) do
    instance_double(Sheetah::Specification)
  end

  let(:processor) do
    described_class.new(specification)
  end

  let(:sheet_class) do
    Class.new { include Sheetah::Sheet }
  end

  let(:backend_args) do
    [double, double]
  end

  let(:backend_opts) do
    { foo: double, bar: double }
  end

  let(:sheet) do
    instance_double(sheet_class)
  end

  def call(&block)
    block ||= proc {} # stub a dummy proc
    processor.call(*backend_args, backend: sheet_class, **backend_opts, &block)
  end

  def stub_sheet_open_ok(success = double)
    allow(sheet_class).to(
      receive(:open)
      .with(*backend_args, **backend_opts)
      .and_yield(sheet)
      .and_return(Success(success))
    )

    success
  end

  def stub_sheet_open_ko(failure = double)
    allow(sheet_class).to(
      receive(:open)
      .with(*backend_args, **backend_opts)
      .and_return(Failure(failure))
    )

    failure
  end

  describe "backend detection" do
    it "can rely on the explicit argument" do
      actual_args = backend_args
      actual_opts = backend_opts.merge(backend: sheet_class)

      expect(Sheetah::Backends).to(
        receive(:open)
        .with(*actual_args, **actual_opts)
        .and_return(Success())
      )

      result = processor.call(*actual_args, **actual_opts)

      expect(result).to eq(
        Sheetah::SheetProcessorResult.new(
          result: Success(),
          messages: []
        )
      )
    end

    it "can rely on the implicit detection" do
      actual_args = backend_args
      actual_opts = backend_opts

      expect(Sheetah::Backends).to(
        receive(:open)
        .with(*actual_args, **actual_opts)
        .and_return(Success())
      )

      result = processor.call(*actual_args, **actual_opts)

      expect(result).to eq(
        Sheetah::SheetProcessorResult.new(
          result: Success(),
          messages: []
        )
      )
    end
  end

  context "when there is a sheet error" do
    let(:error) do
      instance_double(Sheetah::Sheet::Error, msg_code: code)
    end

    let(:code) do
      double
    end

    before do
      stub_sheet_open_ko(error)
    end

    it "is an empty failure, with messages" do
      expect(call).to eq(
        Sheetah::SheetProcessorResult.new(
          result: Failure(),
          messages: [
            Sheetah::Messaging::Message.new(
              code: code,
              code_data: nil,
              scope: "SHEET",
              scope_data: nil,
              severity: "ERROR"
            ),
          ]
        )
      )
    end
  end

  shared_context "when there is no sheet error" do
    let(:sheet_headers) do
      Array.new(2) { instance_double(Sheetah::Sheet::Header) }
    end

    let(:sheet_rows) do
      Array.new(3) { instance_double(Sheetah::Sheet::Row) }
    end

    let(:messenger) do
      instance_double(Sheetah::Messaging::Messenger, messages: double)
    end

    let(:headers) do
      instance_double(Sheetah::Headers)
    end

    def stub_messenger
      allow(Sheetah::Messaging::Messenger).to(
        receive(:new)
        .with(no_args)
        .and_return(messenger)
      )
    end

    def stub_enumeration(obj, method_name, enumerable)
      enum = Enumerator.new do |yielder|
        enumerable.each { |item| yielder << item }
        obj
      end

      allow(obj).to receive(method_name).with(no_args) do |&block|
        enum.each(&block)
      end
    end

    def stub_headers
      allow(Sheetah::Headers).to(
        receive(:new)
        .with(specification: specification, messenger: messenger)
        .and_return(headers)
      )
    end

    def stub_headers_ops(result)
      sheet_headers.each do |sheet_header|
        expect(headers).to receive(:add).with(sheet_header).ordered
      end

      expect(headers).to receive(:result).and_return(result).ordered
    end

    before do
      stub_messenger
      stub_headers

      stub_sheet_open_ok

      stub_enumeration(sheet, :each_header, sheet_headers)
      stub_enumeration(sheet, :each_row, sheet_rows)
    end
  end

  context "when there is a header error" do
    include_context "when there is no sheet error"

    before do
      stub_headers_ops(Failure())
    end

    it "is an empty failure, with messages" do
      result = call

      expect(result).to eq(
        Sheetah::SheetProcessorResult.new(
          result: Failure(),
          messages: messenger.messages
        )
      )
    end
  end

  context "when there is no error" do
    include_context "when there is no sheet error"

    let(:headers_spec) do
      double
    end

    let(:processed_rows) do
      Array.new(sheet_rows.size) { double }
    end

    def stub_row_processing
      allow(Sheetah::RowProcessor).to(
        receive(:new)
        .with(headers: headers_spec, messenger: messenger)
        .and_return(row_processor = instance_double(Sheetah::RowProcessor))
      )

      sheet_rows.zip(processed_rows) do |row, processed_row|
        allow(row_processor).to receive(:call).with(row).and_return(processed_row)
      end
    end

    before do
      stub_headers_ops(Success(headers_spec))

      stub_row_processing
    end

    it "is an empty success, with messages" do
      result = call

      expect(result).to eq(
        Sheetah::SheetProcessorResult.new(
          result: Success(),
          messages: messenger.messages
        )
      )
    end

    it "yields each processed row" do
      expect { |b| call(&b) }.to yield_successive_args(*processed_rows)
    end
  end
end
