# frozen_string_literal: true

require "sheetah/utils/cell_string_cleaner"

RSpec.describe Sheetah::Utils::CellStringCleaner do
  subject(:cleaner) { described_class }

  let(:spaces) { "  \t\r\n" }
  let(:nonprints) { "\x00\x1B" }
  let(:garbage) { spaces + nonprints }

  # NOTE: the line return and newline characters act as traps for single-line regexes
  let(:string) { "foo#{spaces}\r\n#{nonprints}bar" }

  it "removes spaces & non-printable characters around a string" do
    expect(cleaner.call(garbage)).to eq("")
    expect(cleaner.call(garbage + string)).to eq(string)
    expect(cleaner.call(string + garbage)).to eq(string)
    expect(cleaner.call(garbage + string + garbage)).to eq(string)
  end
end
