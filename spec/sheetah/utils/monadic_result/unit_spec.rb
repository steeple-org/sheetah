# frozen_string_literal: true

require "sheetah/utils/monadic_result"

RSpec.describe Sheetah::Utils::MonadicResult::Unit do
  subject(:unit) { described_class }

  it { is_expected.to be_frozen }

  it "can be stringified" do
    expect(unit.to_s).to eq("Unit")
  end

  it "can be inspected" do
    expect(unit.inspect).to eq("Unit")
  end
end
