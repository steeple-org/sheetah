# frozen_string_literal: true

require "sheetah/sheet"

RSpec.shared_context "sheet_factories" do
  def header(...)
    Sheetah::Sheet::Header.new(...)
  end

  def row(...)
    Sheetah::Sheet::Row.new(...)
  end

  def cell(...)
    Sheetah::Sheet::Cell.new(...)
  end

  def cells(values, row:, col: 1)
    values.map.with_index(col) do |value, cell_col|
      cell(row: row, col: cell_col, value: value)
    end
  end
end
