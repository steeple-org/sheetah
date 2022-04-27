# frozen_string_literal: true

RSpec.shared_examples "cast_class" do
  subject(:cast_class) { described_class } unless method_defined?(:cast_class) # rubocop:disable RSpec/LeadingSubject

  let(:cast) do
    cast_class.new
  end

  describe "#initialize" do
    it "tolerates any kwargs" do
      expect do
        cast_class.new(foo: double, qoifzj: double)
      end.not_to raise_error
    end
  end

  describe "#call" do
    it "has the right cast signature" do
      expect(cast).to respond_to(:call).with(2).arguments
    end
  end
end
