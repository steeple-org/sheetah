# frozen_string_literal: true

module Sheetah
  class RowProcessor
    def initialize(headers:)
      @headers = headers
    end

    def call(row)
      @headers.zip(row.value)
    end
  end
end
