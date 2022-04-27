# frozen_string_literal: true

# :nocov: #

require "sheetah"

Sheetah::Types::Type.all(&:freeze)

# :nocov: #
