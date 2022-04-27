# frozen_string_literal: true

require "sheetah/backends/wrapper"
require "support/shared/sheet_factories"

RSpec.describe Sheetah::Backends::Wrapper do
  include_context "sheet_factories"

  let(:raw_table) do
    Array.new(4) do |row|
      Array.new(4) do |col|
        instance_double(Object, "(#{row},#{col})")
      end.freeze
    end.freeze
  end

  let(:sheet) do
    new_sheet(raw_table)
  end

  let(:table_interface) do
    Module.new do
      def [](_); end
      def size; end
    end
  end

  let(:headers_interface) do
    Module.new do
      def [](_); end
      def size; end
    end
  end

  let(:values_interfaces) do
    Module.new do
      def [](_); end
    end
  end

  def stub_table(source, target = instance_double(table_interface)) # rubocop:disable Metrics/AbcSize
    return if source.nil?

    source.each_with_index do |source_row, y|
      target_row = instance_double(y.zero? ? headers_interface : values_interfaces)
      allow(target).to receive(:[]).with(y).and_return(target_row)

      source_row.each_with_index do |source_cell, x|
        allow(target_row).to receive(:[]).with(x).and_return(source_cell)
      end
    end

    allow(target).to receive(:size).with(no_args).and_return(source.size)
    allow(target[0]).to receive(:size).with(no_args).and_return(source[0].size) unless source.empty?

    target
  end

  def new_sheet(...)
    described_class.new(stub_table(...))
  end

  describe "#each_header" do
    let(:expected_headers) do
      [
        header(value: raw_table[0][0], col: 1),
        header(value: raw_table[0][1], col: 2),
        header(value: raw_table[0][2], col: 3),
        header(value: raw_table[0][3], col: 4),
      ]
    end

    context "with a block" do
      it "yields each header, with its 1-based index" do
        expect { |b| sheet.each_header(&b) }.to yield_successive_args(*expected_headers)
      end

      it "returns self" do
        expect(sheet.each_header { double }).to be(sheet)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = sheet.each_header

        expect(enum).to be_a(Enumerator)
        expect(enum.size).to be(4)
        expect(enum.to_a).to eq(expected_headers)
      end
    end
  end

  describe "#each_row" do
    let(:expected_rows) do
      [
        row(row: 1, value: cells(raw_table[1], row: 1)),
        row(row: 2, value: cells(raw_table[2], row: 2)),
        row(row: 3, value: cells(raw_table[3], row: 3)),
      ]
    end

    context "with a block" do
      it "yields each row, with its 1-based index" do
        expect { |b| sheet.each_row(&b) }.to yield_successive_args(*expected_rows)
      end

      it "returns self" do
        expect(sheet.each_row { double }).to be(sheet)
      end
    end

    context "without a block" do
      it "returns an enumerator" do
        enum = sheet.each_row

        expect(enum).to be_a(Enumerator)
        expect(enum.size).to be_nil
        expect(enum.to_a).to eq(expected_rows)
      end
    end
  end

  describe "#close" do
    it "returns nil" do
      expect(sheet.close).to be_nil
    end
  end

  context "when the input table is odd" do
    shared_examples "empty_sheet" do
      it "doesn't enumerate any header" do
        expect { |b| sheet.each_header(&b) }.not_to yield_control
      end

      it "doesn't enumerate any row" do
        expect { |b| sheet.each_row(&b) }.not_to yield_control
      end
    end

    context "when the input table is nil" do
      it "raises an error" do
        expect { new_sheet(nil) }.to raise_error(Sheetah::Sheet::Error)
      end
    end

    context "when the input table is empty" do
      let(:sheet) { new_sheet [] }

      include_examples "empty_sheet"
    end

    context "when the input table headers are empty" do
      let(:sheet) { new_sheet [[]] }

      include_examples "empty_sheet"
    end
  end
end
