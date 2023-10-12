# frozen_string_literal: true

require "sheetah/backends/csv"
require "support/shared/sheet_factories"
require "csv"
require "stringio"

RSpec.describe Sheetah::Backends::Csv do
  include_context "sheet_factories"

  let(:raw_table) do
    Array.new(4) do |row|
      Array.new(4) do |col|
        "(#{row},#{col})"
      end.freeze
    end.freeze
  end

  let(:raw_sheet) do
    stub_sheet(raw_table)
  end

  let(:sheet) do
    described_class.new(raw_sheet)
  end

  def stub_sheet(table)
    csv = CSV.generate do |csv_io|
      table.each do |row|
        csv_io << row
      end
    end

    StringIO.new(csv, "r:UTF-8")
  end

  def new_sheet(...)
    described_class.new(stub_sheet(...))
  end

  describe "#initialize" do
    let(:utf8_path) { fixture_path("csv/utf8.csv") }
    let(:latin9_path) { fixture_path("csv/latin9.csv") }

    let(:headers) do
      [
        "Matricule",
        "Nom",
        "Prénom",
        "Email",
        "Date de naissance",
        "Entrée en entreprise",
        "Administrateur",
        "Bio",
        "Service",
      ]
    end

    let(:sheet) { described_class.new(io) }
    let(:sheet_headers) { sheet.each_header.map(&:value) }

    context "when the IO is opened with a correct external encoding" do
      let(:io) do
        File.new(latin9_path, external_encoding: Encoding::ISO_8859_15)
      end

      it "does not fail" do
        expect { sheet }.not_to raise_error
      end
    end

    context "when the IO is opened with an incorrect external encoding" do
      let(:io) do
        File.new(latin9_path, external_encoding: Encoding::UTF_8)
      end

      it "fails" do
        expect { sheet }.to raise_error(described_class::InvalidCSVError)
      end
    end

    context "when the IO is setup with different encodings" do
      let(:io) do
        File.new(
          utf8_path,
          external_encoding: Encoding::UTF_8,
          internal_encoding: Encoding::ISO_8859_15
        )
      end

      it "does not interfere" do
        latin9_headers = headers.map { |str| str.encode(Encoding::ISO_8859_15) }

        expect(sheet_headers).to eq(latin9_headers)
      end
    end
  end

  describe "#each_header" do
    let(:expected_headers) do
      [
        header(value: raw_table[0][0], col: "A"),
        header(value: raw_table[0][1], col: "B"),
        header(value: raw_table[0][2], col: "C"),
        header(value: raw_table[0][3], col: "D"),
      ]
    end

    context "with a block" do
      it "yields each header, with its letter-based index" do
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

    it "doesn't close the underlying sheet" do
      expect { sheet.close }.not_to change(raw_sheet, :closed?).from(false)
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

    context "when the input table is empty" do
      let(:sheet) { new_sheet [] }

      include_examples "empty_sheet"
    end

    context "when the input table headers are empty" do
      let(:sheet) { new_sheet [[]] }

      include_examples "empty_sheet"
    end
  end

  describe "CSV options" do
    it "requires a specific col_sep and quote_char, and an automatic row_sep" do
      expect(CSV).to receive(:new)
        .with(raw_sheet, row_sep: :auto, col_sep: ",", quote_char: '"')
        .and_call_original

      sheet
    end
  end
end
