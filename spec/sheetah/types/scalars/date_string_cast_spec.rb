# frozen_string_literal: true

require "sheetah/types/scalars/date_string_cast"
require "sheetah/messaging"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Scalars::DateStringCast do
  let(:default_fmt) do
    "%Y-%m-%d"
  end

  it_behaves_like "cast_class"

  describe "#initialize" do
    it "setups a default, conventional date format and accepts native dates" do
      expect(described_class.new).to eq(
        described_class.new(date_fmt: default_fmt, accept_date: true)
      )
    end
  end

  describe "#call" do
    let(:value) { double }
    let(:messenger) { instance_double(Sheetah::Messaging::Messenger) }

    context "when value is a Date" do
      subject(:cast) do
        described_class.new(accept_date: accept_date)
      end

      before do
        allow(::Date).to receive(:===).with(value).and_return(true)
      end

      context "when accepting Date" do
        let(:accept_date) { true }

        it "returns the value" do
          expect(cast.call(value, messenger)).to eq(value)
        end
      end

      context "when not accepting Date" do
        let(:accept_date) { false }

        it "fails with an error" do
          expect(messenger).to receive(:error).with("must_be_date", format: default_fmt)
          expect { cast.call(value, messenger) }.to throw_symbol(:failure, nil)
        end
      end
    end

    context "when value is a string" do
      subject(:cast) do
        described_class.new(date_fmt: date_fmt)
      end

      let(:date_fmt) { "%d/%m/%Y" }

      context "when it fits the format" do
        let(:value) do
          "07/03/2020"
        end

        it "returns a Date" do
          expect(cast.call(value, messenger)).to eq(Date.new(2020, 3, 7))
        end
      end

      context "when it doesn't make sense" do
        let(:value) do
          "47/03/2020"
        end

        it "fails with an error" do
          expect(messenger).to receive(:error).with("must_be_date", format: date_fmt)
          expect { cast.call(value, messenger) }.to throw_symbol(:failure, nil)
        end
      end

      context "when it doesn't fit the format" do
        let(:value) do
          "2020-01-12"
        end

        it "fails with an error" do
          expect(messenger).to receive(:error).with("must_be_date", format: date_fmt)
          expect { cast.call(value, messenger) }.to throw_symbol(:failure, nil)
        end
      end
    end

    context "when value is anything else" do
      subject(:cast) do
        described_class.new
      end

      it "fails with an error" do
        expect(messenger).to receive(:error).with("must_be_date", format: default_fmt)
        expect { cast.call(value, messenger) }.to throw_symbol(:failure, nil)
      end
    end
  end
end
