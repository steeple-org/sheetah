# frozen_string_literal: true

module Sheetah
  class BackendsRegistry
    def initialize
      @registry = {}
    end

    def set(backend, &matcher)
      @registry[backend] = matcher
      self
    end

    def get(*args, **opts)
      @registry.each do |backend, matcher|
        matcher.call(args, opts)
      rescue NoMatchingPatternError
        next
      else
        return backend
      end

      nil
    end

    def freeze
      @registry.freeze
      super
    end
  end
end
