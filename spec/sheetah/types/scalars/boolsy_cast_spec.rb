# frozen_string_literal: true

require "sheetah/types/scalars/boolsy_cast"
require "sheetah/messaging"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Scalars::BoolsyCast do
  it_behaves_like "cast_class"

  describe "#initialize" do
    it "setups default, conventional boolsy values" do
      expect(described_class.new).to eq(
        described_class.new(truthy: [true], falsy: [false])
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

    it "returns true when the value is truthy" do
      stub_inclusion(truthy, value, true)

      expect(cast.call(value, messenger)).to be(true)
    end

    it "returns false when the value is falsy" do
      stub_inclusion(truthy, value, false)
      stub_inclusion(falsy, value, true)

      expect(cast.call(value, messenger)).to be(false)
    end

    it "adds an error message and throws :failure otherwise" do
      stub_inclusion(truthy, value, false)
      stub_inclusion(falsy, value, false)

      expect(messenger).to receive(:error).with("must_be_boolsy", value: value.inspect)
      expect { cast.call(value, messenger) }.to throw_symbol(:failure, nil)
    end
  end
end
