# frozen_string_literal: true

require "sheetah/specification"

RSpec.describe Sheetah::Specification do
  let(:spec) do
    described_class.new
  end

  describe "#set" do
    it "rejects nil patterns" do
      pattern = nil
      column = double

      expect do
        spec.set(pattern, column)
      end.to raise_error(described_class::InvalidPatternError, "nil")
    end

    it "rejects mutable patterns" do
      pattern = instance_double(Object, frozen?: false, inspect: "mutable_pattern_inspect")
      column = double

      expect do
        spec.set(pattern, column)
      end.to raise_error(described_class::MutablePatternError, "mutable_pattern_inspect")
    end

    it "rejects duplicated patterns" do
      pattern = instance_double(Object, frozen?: true, inspect: "pattern_dup")
      column0 = double
      column1 = double

      spec.set(pattern, column0)

      expect do
        spec.set(pattern, column0)
      end.to raise_error(described_class::DuplicatedPatternError, "pattern_dup")

      expect do
        spec.set(pattern, column1)
      end.to raise_error(described_class::DuplicatedPatternError, "pattern_dup")
    end

    it "accepts unique, frozen patterns" do
      pattern1 = instance_double(Object, frozen?: true, inspect: "pattern1")
      pattern2 = instance_double(Object, frozen?: true, inspect: "pattern2")
      column = double

      expect do
        spec.set(pattern1, column)
        spec.set(pattern2, column)
      end.not_to raise_error
    end

    context "when frozen" do
      it "cannot set new patterns" do
        spec.freeze

        pattern = instance_double(Object, frozen?: true)
        column = double

        expect do
          spec.set(pattern, column)
        end.to raise_error(FrozenError)
      end
    end
  end

  describe "#get" do
    let(:regexp_pattern) do
      /foo\d{3}bar/i
    end

    let(:string_pattern) do
      "Doubitchou"
    end

    let(:other_pattern) do
      instance_double(Object, frozen?: true)
    end

    let(:columns) do
      Array.new(3) { double }
    end

    before do
      spec.set(string_pattern, columns[0])
      spec.set(regexp_pattern, columns[1])
      spec.set(other_pattern, columns[2])
    end

    it "returns nil when header is nil" do
      expect(spec.get(nil)).to be_nil
    end

    context "with a Regexp pattern" do
      it "returns the matching column" do
        expect(spec.get("foo123bar")).to eq(columns[1])
        expect(spec.get("Foo480BAR")).to eq(columns[1])
      end
    end

    context "with a String pattern" do
      it "returns the matching column" do
        expect(spec.get("Doubitchou")).to eq(columns[0])
      end

      it "matches case-sensitively" do
        expect(spec.get("doubitchou")).to be_nil
      end
    end

    context "with any other pattern" do
      let(:header) { "boudoudou" }

      it "matches an equivalent header" do
        allow(other_pattern).to receive(:==).with(header).and_return(true)
        expect(spec.get(header)).to eq(columns[2])
      end

      it "doesn't match a non-equivalent header" do
        allow(other_pattern).to receive(:==).with(header).and_return(false)
        expect(spec.get(header)).to be_nil
      end
    end

    context "when frozen" do
      it "can get existing patterns" do
        spec.freeze

        expect(spec.get("Doubitchou")).to eq(columns[0])
      end
    end
  end

  describe "errors" do
    example "invalid pattern" do
      expect(described_class::InvalidPatternError).to have_attributes(
        superclass: Sheetah::Errors::SpecError,
        msg_code: "sheetah.specification.invalid_pattern_error"
      )
    end

    example "mutable pattern" do
      expect(described_class::MutablePatternError).to have_attributes(
        superclass: Sheetah::Errors::SpecError,
        msg_code: "sheetah.specification.mutable_pattern_error"
      )
    end

    example "duplicated pattern" do
      expect(described_class::DuplicatedPatternError).to have_attributes(
        superclass: Sheetah::Errors::SpecError,
        msg_code: "sheetah.specification.duplicated_pattern_error"
      )
    end
  end
end
