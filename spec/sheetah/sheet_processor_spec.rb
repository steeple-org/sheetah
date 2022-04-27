# frozen_string_literal: true

require "sheetah/sheet_processor"

RSpec.describe Sheetah::SheetProcessor, monadic_result: true do
  let(:processor) do
    described_class.new
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

  def stub_sheet_open_ok(success)
    allow(sheet_class).to(
      receive(:open)
      .with(*backend_args, **backend_opts)
      .and_yield(sheet)
      .and_return(Success(success))
    )
  end

  def stub_sheet_open_ko(failure)
    allow(sheet_class).to(
      receive(:open)
      .with(*backend_args, **backend_opts)
      .and_return(Failure(failure))
    )
  end

  context "when there is a sheet error" do
    let(:error_class) do
      Class.new(Sheetah::Sheet::Error)
    end

    let(:error) do
      error_class.exception
    end

    before do
      stub_sheet_open_ko(error)
    end

    it "is an empty failure" do
      result = call

      expect(result).to eq(Failure())
    end
  end

  context "when there is no sheet error" do
    let(:sheet_headers) do
      Array.new(2) { instance_double(Sheetah::Sheet::Header) }
    end

    let(:sheet_rows) do
      Array.new(3) { instance_double(Sheetah::Sheet::Row) }
    end

    let(:processed_rows) do
      Array.new(sheet_rows.size) { double }
    end

    let(:sheet_open_success) do
      double
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

    def stub_row_processing
      allow(Sheetah::RowProcessor).to(
        receive(:new)
        .with(headers: sheet_headers)
        .and_return(row_processor = instance_double(Sheetah::RowProcessor))
      )

      sheet_rows.zip(processed_rows) do |row, processed_row|
        allow(row_processor).to receive(:call).with(row).and_return(processed_row)
      end
    end

    before do
      stub_sheet_open_ok(sheet_open_success)

      stub_enumeration(sheet, :each_header, sheet_headers)
      stub_enumeration(sheet, :each_row, sheet_rows)

      stub_row_processing
    end

    it "is an empty success" do
      result = call

      expect(result).to eq(Success())
    end

    it "yields each processed row" do
      expect { |b| call(&b) }.to yield_successive_args(*processed_rows)
    end
  end
end
