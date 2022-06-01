# frozen_string_literal: true

require "sheetah/backends_registry"

RSpec.describe Sheetah::BackendsRegistry do
  let(:registry) { described_class.new }

  let(:backend0) { double(:backend0) }
  let(:backend1) { double(:backend1) }

  before do
    registry.set(backend0) do |args, opts|
      args in [[1, 2, Symbol]]
      opts in { foo: Hash }
    end

    registry.set(backend1) do |args, opts|
      args in []
      opts in { path: /\.csv$/ }
    end
  end

  describe "#get / #set" do
    it "can set a new backend with a matcher" do
      expect(registry.get([1, 2, :ozij], foo: { 1 => 2 })).to be(backend0)
      expect(registry.get(path: "file.csv")).to be(backend1)
      expect(registry.get(double, path: "file.csv")).to be_nil
    end

    it "can overwrite a previous backend matcher" do
      registry.set(backend0) do |args, opts|
        args in ["foo"]
        opts in {}
      end

      expect(registry.get("foo")).to be(backend0)
    end
  end

  describe "#set" do
    it "returns the registry itself" do
      result = registry.set(backend0) {}

      expect(result).to be(registry)
    end
  end

  describe "#freeze" do
    before { registry.freeze }

    it "freezes the registry" do
      expect(registry).to be_frozen
    end

    it "prevents further modifications" do
      expect do
        registry.set(backend0) {}
      end.to raise_error(FrozenError)
    end

    it "doesn't prevent further readings" do
      expect(registry.get(path: "foo.csv")).to be(backend1)
    end
  end
end
