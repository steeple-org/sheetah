# frozen_string_literal: true

require "sheetah/utils/monadic_result"

RSpec.describe Sheetah::Utils::MonadicResult::Success, monadic_result: true do
  subject(:result) { described_class.new(value0) }

  let(:value0) do
    instance_double(Object, to_s: "value0_to_s", inspect: "value0_inspect")
  end

  let(:value1) do
    instance_double(Object, to_s: "value1_to_s", inspect: "value1_inspect")
  end

  it "is a result" do
    expect(result).to be_a(Sheetah::Utils::MonadicResult::Result)
  end

  describe "#initialize" do
    it "is empty by default" do
      expect(described_class.new).to be_empty
    end
  end

  describe "#empty?" do
    it "is true by default of an explicitly wrapped value" do
      expect(described_class.new).to be_empty
    end

    it "is false otherwise" do
      expect(result).not_to be_empty
    end
  end

  describe "#success?" do
    it "is true" do
      expect(result).to be_success
    end
  end

  describe "#failure?" do
    it "is false" do
      expect(result).not_to be_failure
    end
  end

  describe "#success" do
    it "can unwrap the value" do
      expect(result).to have_attributes(success: value0)
    end

    it "cannot unwrap a value when empty" do
      empty_result = described_class.new

      expect { empty_result.success }.to raise_error(
        described_class::ValueError, "There is no value within the result"
      )
    end
  end

  describe "#failure" do
    it "can't unwrap the value" do
      expect { result.failure }.to raise_error(
        described_class::VariantError, "Not a Failure"
      )
    end
  end

  describe "#==" do
    it "is equivalent to a similar Success" do
      expect(result).to eq(Success(value0))
    end

    it "is not equivalent to a different Success" do
      expect(result).not_to eq(Success(value1))
    end

    it "is not equivalent to a similar Failure" do
      expect(result).not_to eq(Failure(value0))
    end
  end

  describe "#inspect" do
    it "inspects the result" do
      expect(result.inspect).to eq("Success(value0_inspect)")
    end

    context "when empty" do
      subject(:result) { described_class.new }

      it "inspects nothing" do
        expect(result.inspect).to eq("Success()")
      end
    end
  end

  describe "#to_s" do
    it "inspects the result" do
      expect(result.method(:to_s)).to eq(result.method(:inspect))
    end
  end

  describe "#unwrap" do
    context "when empty" do
      it "returns nil" do
        result = described_class.new

        expect(result.unwrap).to be_nil
      end
    end

    context "when non-empty" do
      it "returns the wrapped value" do
        result = described_class.new(wrapped = double)

        expect(result.unwrap).to be(wrapped)
      end
    end
  end

  describe "#discard" do
    it "returns the same variant, without a value" do
      empty_result = described_class.new
      filled_result = described_class.new(double)

      expect(empty_result.discard).to eq(empty_result)
      expect(filled_result.discard).to eq(empty_result)
    end
  end

  describe "#bind" do
    context "when empty" do
      let(:result) { described_class.new }

      it "yields nil" do
        expect { |b| result.bind(&b) }.to yield_with_no_args
      end

      it "returns the block result" do
        block_value = double
        expect(result.bind { block_value }).to eq(block_value)
      end
    end

    context "when filled" do
      let(:value) { double }
      let(:result) { described_class.new(value) }

      it "yields the value" do
        expect { |b| result.bind(&b) }.to yield_with_args(value)
      end

      it "returns the block result" do
        block_value = double
        expect(result.bind { block_value }).to eq(block_value)
      end
    end
  end

  describe "#or" do
    context "when empty" do
      let(:result) { described_class.new }

      it "doesn't yield" do
        expect { |b| result.or(&b) }.not_to yield_control
      end

      it "returns self" do
        expect(result.or { double }).to be(result)
      end
    end

    context "when filled" do
      let(:result) { described_class.new(double) }

      it "doesn't yield" do
        expect { |b| result.or(&b) }.not_to yield_control
      end

      it "returns self" do
        expect(result.or { double }).to be(result)
      end
    end
  end
end
