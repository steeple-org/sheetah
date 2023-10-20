# frozen_string_literal: true

require "sheetah/messaging"

RSpec.describe Sheetah::Messaging do
  around do |example|
    config = described_class.config
    example.run
    described_class.config = config
  end

  describe "::config" do
    it "reads a global, frozen instance" do
      expect(described_class.config).to be_a(described_class::Config) & be_frozen
    end
  end

  describe "::config=" do
    it "writes a global instance" do
      described_class.config = (config = double)
      expect(described_class.config).to eq(config)
    end
  end

  describe "::configure" do
    let(:old) { instance_double(described_class::Config, dup: new) }
    let(:new) { instance_double(described_class::Config) }

    before do
      described_class.config = old
    end

    it "modifies a copy of the global instance" do
      expect do |b|
        described_class.configure(&b)
      end.to yield_with_args(new)

      expect(described_class.config).to be(new)
    end
  end
end
