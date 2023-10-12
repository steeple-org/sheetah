# frozen_string_literal: true

require "sheetah/backends/xlsx"
require "support/shared/sheet_factories"

RSpec.describe Sheetah::Backends::Xlsx do
  include_context "sheet_factories"

  let(:sheet) do
    new_sheet("xlsx/regular.xlsx")
  end

  def new_sheet(path)
    described_class.new(path && fixture_path(path))
  end

  describe "#each_header" do
    let(:expected_headers) do
      [
        header(value: "matricule", col: "A"),
        header(value: "nom", col: "B"),
        header(value: "prénom", col: "C"),
        header(value: "date de naissance", col: "D"),
        header(value: "email", col: "E"),
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
        expect(enum.size).to be(5)
        expect(enum.to_a).to eq(expected_headers)
      end
    end
  end

  describe "#each_row" do
    let(:row1_cells) do
      ["004774", "Ytärd", "Glœuiçe", "28/04/1998", "foo@bar.com"]
    end

    let(:row2_cells) do
      [664_623, "Goulijambon", "Carasmine", Date.new(1976, 1, 20), "foo@bar.com"]
    end

    let(:expected_rows) do
      [
        row(row: 1, value: cells(row1_cells, row: 1)),
        row(row: 2, value: cells(row2_cells, row: 2)),
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
      let(:sheet) { new_sheet("xlsx/empty.xlsx") }

      include_examples "empty_sheet"
    end

    context "when the input table includes empty lines around the content" do
      let(:sheet) { new_sheet("xlsx/empty_lines_around.xlsx") }

      it "doesn't ignore them when detecting the headers" do
        expect { |b| sheet.each_header(&b) }.to yield_control.exactly(5).times
        expect(sheet.each_header.map(&:value)).to all(be_nil)
      end

      it "ignores them when detecting the rows" do
        expect { |b| sheet.each_row(&b) }.to yield_control.exactly(3).times
      end
    end

    context "when the input table includes empty lines within the content" do
      let(:sheet) { new_sheet("xlsx/empty_lines_within.xlsx") }

      it "doesn't impact the detection of headers" do
        expect { |b| sheet.each_header(&b) }.to yield_control.exactly(5).times
      end

      it "doesn't ignore them when detecting the rows" do
        expect { |b| sheet.each_row(&b) }.to yield_control.exactly(4).times
      end
    end
  end
end
