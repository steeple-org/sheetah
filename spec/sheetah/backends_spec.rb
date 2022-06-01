# frozen_string_literal: true

require "sheetah/backends"

RSpec.describe Sheetah::Backends do
  describe "::registry" do
    it "is a registry of backends" do
      expect(described_class.registry).to be_a(Sheetah::BackendsRegistry)
    end
  end

  describe "::open" do
    let(:backend) do
      double
    end

    let(:foo) { double }
    let(:bar) { double }
    let(:res) { double }

    it "may open with an explicit backend" do
      allow(backend).to receive(:open).with(foo, bar: bar).and_return(res)
      expect(described_class.registry).not_to receive(:get)

      expect(described_class.open(foo, backend: backend, bar: bar)).to be(res)
    end

    it "may open with an implicit backend" do
      allow(backend).to receive(:open).with(foo, bar: bar).and_return(res)
      allow(described_class.registry).to receive(:get).with(foo, bar: bar).and_return(backend)

      expect(described_class.open(foo, bar: bar)).to be(res)
    end

    it "may miss a backend to open" do
      allow(described_class.registry).to receive(:get).with(foo, bar: bar).and_return(nil)

      result = described_class.open(foo, bar: bar)
      expect(result).to be_failure
      expect(result.failure).to have_attributes(msg_code: "no_applicable_backend")
    end
  end
end
