# frozen_string_literal: true

require "sheetah/backends"

RSpec.describe Sheetah::Backends do
  describe "::open" do
    let(:backend) do
      double
    end

    let(:foo) { double }
    let(:bar) { double }
    let(:res) { double }

    it "may open with an explicit backend" do
      allow(backend).to receive(:open).with(foo, bar: bar).and_return(res)

      expect(described_class.open(foo, backend: backend, bar: bar)).to be(res)
    end
  end
end
