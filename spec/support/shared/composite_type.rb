# frozen_string_literal: true

require "sheetah/types/type"
require "sheetah/types/scalars/scalar"

RSpec.shared_examples "composite_type" do
  subject(:type) do
    described_class.new(scalars)
  end

  let(:scalars) { instance_double(Array) }

  let(:value) { double }
  let(:messenger) { double }

  it "is a type" do
    expect(described_class.ancestors).to include(Sheetah::Types::Type)
  end

  describe "#composite?" do
    it "is true" do
      expect(subject).to be_composite
    end
  end

  describe "#composite" do
    it "is an alias to #cast" do
      expect(subject.method(:composite)).to eq(subject.method(:cast))
    end
  end

  describe "#scalar" do
    let(:type_index) { double }

    def stub_scalar_index(type = double)
      allow(scalars).to receive(:[]).with(type_index).and_return(type)
      type
    end

    context "when the index refers to a scalar type" do
      let(:scalar_type) { instance_double(Sheetah::Types::Scalars::Scalar) }

      before do
        stub_scalar_index(scalar_type)
      end

      it "casts the value to the scalar type" do
        expect(scalar_type).to(
          receive(:scalar).with(nil, value, messenger).and_return(casted_value = double)
        )

        expect(subject.scalar(type_index, value, messenger)).to be(casted_value)
      end
    end

    context "when the index doesn't refer to a scalar type" do
      before do
        stub_scalar_index(nil)
      end

      it "raises an error" do
        expect { subject.scalar(type_index, value, messenger) }.to raise_error(
          Sheetah::Errors::TypeError,
          "Invalid index: #{type_index.inspect}"
        )
      end
    end
  end
end
