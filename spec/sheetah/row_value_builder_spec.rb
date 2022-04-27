# frozen_string_literal: true

require "sheetah/row_value_builder"
require "sheetah/column"
require "sheetah/types/scalars/scalar"

RSpec.describe Sheetah::RowValueBuilder, monadic_result: true do
  let(:builder) do
    described_class.new(messenger)
  end

  let(:messenger) { double }

  let(:scalar_type) { instance_double(Sheetah::Types::Type, composite?: false) }
  let(:scalar_key) { double }

  let(:composite_type) { instance_double(Sheetah::Types::Type, composite?: true) }
  let(:composite_key) { double }

  def stub_scalar(column, value, result)
    allow(column.type).to receive(:scalar).with(column.index, value, messenger).and_return(result)
  end

  def stub_composite(type, value, result)
    allow(type).to receive(:composite).with(value, messenger).and_return(result)
  end

  context "when the column type is scalar" do
    let(:column) do
      instance_double(Sheetah::Column, type: scalar_type, key: scalar_key, index: nil)
    end

    let(:input) { double }
    let(:output) { double }

    context "when the scalar type casting succeeds" do
      before { stub_scalar(column, input, Success(output)) }

      it "returns Success results wrapping type casted values" do
        result = builder.add(column, input)

        expect(result).to eq(Success(output))
        expect(builder.result).to eq(Success(column.key => output))
      end
    end

    context "when the scalar type casting fails" do
      before { stub_scalar(column, input, Failure()) }

      it "returns Failure results" do
        result = builder.add(column, input)

        expect(result).to eq(Failure())
        expect(builder.result).to eq(Failure())
      end
    end
  end

  context "when the column type is composite" do
    let(:column) do
      instance_double(Sheetah::Column, type: composite_type, key: composite_key, index: 0)
    end

    let(:scalar_input) { double }
    let(:scalar_output) { double }

    context "when the scalar type casting succeeds" do
      before { stub_scalar(column, scalar_input, Success(scalar_output)) }

      context "when the composite type casting succeeds" do
        let(:composite_output) { double }

        before do
          stub_composite(composite_type, [scalar_output], Success(composite_output))
        end

        it "returns Success results wrapping type casted values" do
          result = builder.add(column, scalar_input)

          expect(result).to eq(Success(scalar_output))
          expect(builder.result).to eq(Success(column.key => composite_output))
        end
      end

      context "when the composite type casting fails" do
        before { stub_composite(composite_type, [scalar_output], Failure()) }

        it "returns Success and Failure appropriately" do
          result = builder.add(column, scalar_input)

          expect(result).to eq(Success(scalar_output))
          expect(builder.result).to eq(Failure())
        end
      end
    end

    context "when the scalar type casting fails" do
      before { stub_scalar(column, scalar_input, Failure()) }

      it "returns Failure results" do
        result = builder.add(column, scalar_input)

        expect(result).to eq(Failure())
        expect(builder.result).to eq(Failure())
      end
    end
  end

  context "when handling multiple columns in any order" do
    let(:column0) do
      instance_double(Sheetah::Column, type: composite_type, key: composite_key, index: 2)
    end

    let(:column1) do
      instance_double(Sheetah::Column, type: composite_type, key: composite_key, index: 1)
    end

    let(:column2) do
      instance_double(Sheetah::Column, type: scalar_type, key: scalar_key, index: nil)
    end

    it "reduces them to a correctly typed aggregate" do
      stub_scalar(column0, in0 = double, Success(out0 = double))
      stub_scalar(column1, in1 = double, Success(out1 = double))
      stub_scalar(column2, in2 = double, Success(out2 = double))

      builder.add(column0, in0)
      builder.add(column2, in2)
      builder.add(column1, in1)

      stub_composite(composite_type, [nil, out1, out0], Success(composite_out = double))

      expect(builder.result).to eq(
        Success(
          composite_key => composite_out,
          scalar_key => out2
        )
      )
    end
  end
end
