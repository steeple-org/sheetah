# frozen_string_literal: true

return unless ENV.fetch("COVERAGE", nil) == "true"

require "simplecov"

SimpleCov.start do
  enable_coverage :branch
end
