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

  it "includes three builder methods" do
    expect(builder.methods - Object.methods).to contain_exactly(
      :Success, :Failure, :Do
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

  describe "#Do" do
    let(:v1) { double }
    let(:v2) { double }
    let(:v3) { double }
    let(:v4) { double }
    let(:v5) { double }

    it "returns the last expression of the block" do
      result = builder.Do do
        v1
        v2
        v3
      end

      expect(result).to be(v3)
    end

    it "continues the sequence when unwrapping a Success" do
      v = nil

      result = builder.Do do
        v = builder.Success(v1).unwrap
        v = builder.Success(v2).unwrap
        v = builder.Success(v3).unwrap
      end

      expect(result).to be(v3)
      expect(v).to be(v3)
    end

    it "aborts the sequence when unwrapping a Failure" do
      v = nil

      result = builder.Do do
        v = builder.Success(v1).unwrap
        v = builder.Failure(v2).unwrap
        # :nocov:
        v = builder.Success(v3).unwrap
        # :nocov:
      end

      expect(result).to eq(builder.Failure(v2))
      expect(v).to be(v1)
    end

    it "is compatible with ensure" do
      ensured = false

      builder.Do do
        builder.Failure().unwrap
      ensure
        ensured = true
      end

      expect(ensured).to be(true)
    end
  end
end
