# frozen_string_literal: true

require "sheetah/utils/monadic_result"

RSpec.configure do |config|
  config.include(Sheetah::Utils::MonadicResult, monadic_result: true)
end
