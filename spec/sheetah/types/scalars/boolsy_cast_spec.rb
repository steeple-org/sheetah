# frozen_string_literal: true

require "sheetah/types/scalars/boolsy_cast"
require "sheetah/messaging"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Scalars::BoolsyCast do
  it_behaves_like "cast_class"

  describe "#initialize" do
    it "setups blank boolsy values by default" do
      expect(described_class.new).to eq(
        described_class.new(truthy: [], falsy: [])
      )
    end
  end

  describe "#call" do
    subject(:cast) { described_class.new(truthy: truthy, falsy: falsy) }

    let(:value) { instance_double(Object, inspect: double) }
    let(:messenger) { instance_double(Sheetah::Messaging::Messenger) }

    let(:truthy) do
      instance_double(Array)
    end

    let(:falsy) do
      instance_double(Array)
    end

    def stub_inclusion(set, value, bool)
      allow(set).to receive(:include?).with(value).and_return(bool)
    end

    def expect_truthy(value = self.value)
      expect(cast.call(value, messenger)).to be(true)
    end

    def expect_falsy(value = self.value)
      expect(cast.call(value, messenger)).to be(false)
    end

    def expect_failure(value = self.value)
      expect(messenger).to receive(:error).with("must_be_boolsy", value: value.inspect)
      expect { cast.call(value, messenger) }.to throw_symbol(:failure, nil)
    end

    context "when the value is truthy" do
      before do
        stub_inclusion(truthy, value, true)
        stub_inclusion(falsy, value, false)
      end

      it "returns true" do
        expect_truthy
      end
    end

    context "when the value is falsy" do
      before do
        stub_inclusion(truthy, value, false)
        stub_inclusion(falsy, value, true)
      end

      it "returns false" do
        expect_falsy
      end
    end

    context "when the value isn't truthy nor falsy" do
      before do
        stub_inclusion(truthy, value, false)
        stub_inclusion(falsy, value, false)
      end

      it "fails with a message" do
        expect_failure
      end
    end
  end
end
