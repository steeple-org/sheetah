# frozen_string_literal: true

require "sheetah/messaging/config"

RSpec.describe Sheetah::Messaging::Config do
  describe "#validate_messages" do
    it "may be false" do
      config = described_class.new(validate_messages: false)
      expect(config.validate_messages).to be(false)
    end

    it "may be true" do
      config = described_class.new(validate_messages: true)
      expect(config.validate_messages).to be(true)
    end
  end

  describe "#validate_messages=" do
    it "can become true" do
      config = described_class.new(validate_messages: false)
      config.validate_messages = true
      expect(config.validate_messages).to be(true)
    end

    it "can become false" do
      config = described_class.new(validate_messages: true)
      config.validate_messages = false
      expect(config.validate_messages).to be(false)
    end
  end
end
