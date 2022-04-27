# frozen_string_literal: true

require "sheetah/utils/monadic_result"

RSpec.describe Sheetah::Utils::MonadicResult do
  let(:klass) do
    Class.new.tap { |c| c.include(described_class) }
  end

  let(:builder) { klass.new }

  let(:value) { double }

  it "includes some constants" do
    expect(klass.constants - Object.constants).to contain_exactly(
      :Unit, :Result, :Success, :Failure
    )

    expect(klass::Unit).to be(described_class::Unit)
    expect(klass::Result).to be(described_class::Result)
    expect(klass::Success).to be(described_class::Success)
    expect(klass::Failure).to be(described_class::Failure)
  end

  it "includes two builder methods" do
    expect(builder.methods - Object.methods).to contain_exactly(
      :Success, :Failure
    )
  end

  describe "#Success" do
    it "may wrap no value in a Success instance" do
      expect(builder.Success()).to eq(described_class::Success.new)
    end

    it "may wrap a value in a Success instance" do
      expect(builder.Success(value)).to eq(described_class::Success.new(value))
    end
  end

  describe "#Failure" do
    it "may wrap no value in a Failure instance" do
      expect(builder.Failure()).to eq(described_class::Failure.new)
    end

    it "may wrap a value in a Failure instance" do
      expect(builder.Failure(value)).to eq(described_class::Failure.new(value))
    end
  end
end
