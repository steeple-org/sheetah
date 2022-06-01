# frozen_string_literal: true

require "sheetah/backends/csv"
require "support/shared/sheet_factories"
require "csv"
require "stringio"
require "tempfile"

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
    described_class.new(io: raw_sheet)
  end

  def stub_sheet(table)
    return if table.nil?

    csv = CSV.generate do |csv_io|
      table.each do |row|
        csv_io << row
      end
    end

    StringIO.new(csv, "r")
  end

  def new_sheet(...)
    described_class.new(io: stub_sheet(...))
  end

  describe "::register" do
    let(:registry) { Sheetah::BackendsRegistry.new }

    before do
      described_class.register(registry)
    end

    it "matches any so-called IO and an optional encoding" do
      io = double

      expect(registry.get(io: io)).to eq(described_class)
      expect(registry.get(io: io, encoding: "UTF-8")).to eq(described_class)
      expect(registry.get(io: io, encoding: Encoding::UTF_8)).to eq(described_class)
    end

    it "matches a CSV path and an optional encoding" do
      expect(registry.get(path: "foo.csv")).to eq(described_class)
      expect(registry.get(path: "foo.csv", encoding: "UTF-8")).to eq(described_class)
      expect(registry.get(path: "foo.csv", encoding: Encoding::UTF_8)).to eq(described_class)
    end

    it "doesn't match any other path" do
      expect(registry.get(path: "foo.tsv")).to be_nil
    end

    it "doesn't match extra args" do
      expect(registry.get(2, path: "foo.csv")).to be_nil
    end
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

    context "when no io nor path is given" do
      it "fails" do
        expect do
          described_class.new
        end.to raise_error(described_class::ArgumentError)
      end
    end

    context "when both an io and a path are given" do
      it "fails" do
        expect do
          described_class.new(io: double, path: double)
        end.to raise_error(described_class::ArgumentError)
      end
    end

    context "when only an io is given" do
      let(:io) { File.new(io_path) }

      context "when the default encoding is valid" do
        alias_method :io_path, :utf8_path

        it "can read CSV data" do
          sheet = described_class.new(io: io)
          expect(sheet.each_header.map(&:value)).to eq(headers)
        end
      end

      context "when the default encoding is invalid" do
        alias_method :io_path, :latin9_path

        it "fails" do
          expect do
            described_class.new(io: io)
          end.to raise_error(described_class::EncodingError)
        end

        it "can read CSV data once given a valid encoding" do
          sheet = described_class.new(io: io, encoding: Encoding::ISO_8859_15)
          expect(sheet.each_header.map(&:value)).to eq(headers)
        end
      end
    end

    context "when only a path is given" do
      context "when the default encoding is valid" do
        alias_method :path, :utf8_path

        it "can read CSV data" do
          sheet = described_class.new(path: path)
          expect(sheet.each_header.map(&:value)).to eq(headers)
        end
      end

      context "when the default encoding is invalid" do
        alias_method :path, :latin9_path

        it "fails" do
          expect do
            described_class.new(path: path)
          end.to raise_error(described_class::EncodingError)
        end

        it "can read CSV data once given a valid encoding" do
          sheet = described_class.new(path: path, encoding: Encoding::ISO_8859_15)
          expect(sheet.each_header.map(&:value)).to eq(headers)
        end
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

    it "closes the underlying sheet" do
      expect { sheet.close }.to change(raw_sheet, :closed?).from(false).to(true)
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

  describe "CSV options" do
    it "requires a specific col_sep and quote_char" do
      expect(CSV).to receive(:new).with(raw_sheet, col_sep: ",", quote_char: '"').and_call_original

      sheet
    end
  end
end
