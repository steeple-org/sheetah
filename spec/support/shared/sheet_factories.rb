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

  def cells(values, row:, col: "A")
    int = Sheetah::Sheet.col2int(col)

    values.map.with_index(int) do |value, index|
      cell(row:, col: Sheetah::Sheet.int2col(index), value:)
    end
  end
end
