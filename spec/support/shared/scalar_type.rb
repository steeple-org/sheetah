# frozen_string_literal: true

require "sheetah/types/type"

RSpec.shared_examples "scalar_type" do
  let(:value) { double }
  let(:messenger) { double }

  it "is a type" do
    expect(described_class.ancestors).to include(Sheetah::Types::Type)
  end

  describe "#composite?" do
    it "is false" do
      expect(subject).not_to be_composite
    end
  end

  describe "#composite" do
    it "fails" do
      expect { subject.composite(value, messenger) }.to raise_error(
        Sheetah::Errors::TypeError, "A scalar type cannot act as a composite"
      )
    end
  end

  describe "#scalar" do
    context "when the value is not indexed" do
      it "delegates the task to the cast chain" do
        result = double

        expect(subject.cast_chain).to receive(:call).with(value, messenger).and_return(result)
        expect(subject.scalar(nil, value, messenger)).to be(result)
      end
    end

    context "when the value is indexed" do
      it "fails" do
        index = double

        expect { subject.scalar(index, value, messenger) }.to raise_error(
          Sheetah::Errors::TypeError, "A scalar type cannot be indexed"
        )
      end
    end
  end
end
