# frozen_string_literal: true

require "sheetah/column"

RSpec.describe Sheetah::Column do
  let(:key) { double }
  let(:type) { double }
  let(:index) { double }
  let(:header) { double }
  let(:header_pattern) { Object.new }

  let(:col) do
    described_class.new(
      key: key,
      type: type,
      index: index,
      header: header,
      header_pattern: header_pattern
    )
  end

  it "is frozen" do
    expect(col).to be_frozen
  end

  describe "#key" do
    it "reads the attribute" do
      expect(col.key).to be(key)
    end
  end

  describe "#type" do
    it "reads the attribute" do
      expect(col.type).to be(type)
    end
  end

  describe "#index" do
    it "reads the attribute" do
      expect(col.index).to be(index)
    end
  end

  describe "#header" do
    it "reads the attribute" do
      expect(col.header).to be(header)
    end
  end

  describe "#header_pattern" do
    it "reads a frozen attribute" do
      expect(col.header_pattern).to be(header_pattern)
      expect(col.header_pattern).to be_frozen
    end

    context "when the value is not given" do
      let(:header_copy) { Object.new }

      let(:col) do
        described_class.new(
          key: key,
          type: type,
          index: index,
          header: header
        )
      end

      before do
        allow(header).to receive(:dup).and_return(header_copy)
      end

      it "defaults to a frozen copy of the header value" do
        expect(col.header).not_to be_frozen
        expect(col.header_pattern).to be(header_copy) & be_frozen
      end
    end
  end
end
