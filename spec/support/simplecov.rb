# frozen_string_literal: true

return unless ENV.fetch("COVERAGE", nil) == "true"

require "simplecov"

SimpleCov.start do
  coverage_dir "docs/coverage"

  enable_coverage :branch
end
