# frozen_string_literal: true

require "sheetah/types/cast_chain"

RSpec.describe Sheetah::Types::CastChain do
  let(:cast_interface) do
    Class.new do
      def call(_value, _messenger); end
    end
  end

  let(:cast) do
    cast_interface.new
  end

  let(:cast0) { cast_double }
  let(:cast1) { cast_double }
  let(:cast2) { cast_double }

  let(:chain) do
    described_class.new([cast0, cast1])
  end

  def cast_double
    instance_double(cast_interface)
  end

  describe "#initialize" do
    it "builds an empty chain by default" do
      chain = described_class.new

      expect(chain.casts).to be_empty
    end

    it "builds a non-empty chain using the optional parameter" do
      chain = described_class.new([cast0, cast1])

      expect(chain.casts).to eq([cast0, cast1])
    end
  end

  describe "#prepend" do
    it "prepends a cast to the chain" do
      chain.prepend(cast2)

      expect(chain.casts).to eq([cast2, cast0, cast1])
    end
  end

  describe "#appends" do
    it "appends a cast to the chain" do
      chain.append(cast2)

      expect(chain.casts).to eq([cast0, cast1, cast2])
    end
  end

  describe "#freeze" do
    it "freezes the whole chain" do
      chain = described_class.new([cast.dup, cast.dup])

      chain.freeze

      expect(chain.casts).to all(be_frozen)
      expect(chain.casts).to be_frozen
      expect(chain).to be_frozen
    end
  end

  describe "#call", monadic_result: true do
    let(:messenger) do
      double
    end

    it "maps the value and passes the messenger to all casts" do
      value0 = double

      expect(cast0).to(receive(:call).with(value0, messenger).and_return(value1 = double))
      expect(cast1).to(receive(:call).with(value1, messenger).and_return(value2 = double))
      expect(cast2).to(receive(:call).with(value2, messenger).and_return(value3 = double))

      chain = described_class.new([cast0, cast1, cast2])

      result = chain.call(value0, messenger)
      expect(result).to eq(Success(value3))
    end

    context "when a cast throws :success without value" do
      it "halts the chain and returns Success(nil)" do
        chain = described_class.new [
          ->(value, _messenger) { value.capitalize },
          ->(_value, _messenger) { throw :success },
          cast_double,
        ]

        result = chain.call("foo", messenger)

        expect(result).to eq(Success(nil))
      end
    end

    context "when a cast throws :success with a value" do
      it "halts the chain and returns Success(<value>)" do
        chain = described_class.new [
          ->(value, _messenger) { value.capitalize },
          ->(_value, _messenger) { throw :success, "bar" },
          cast_double,
        ]

        result = chain.call("foo", messenger)

        expect(result).to eq(Success("bar"))
      end
    end

    context "when a cast throws :failure without a value" do
      it "halts the chain and returns Failure()" do
        chain = described_class.new [
          ->(value, _messenger) { value.capitalize },
          ->(_value, _messenger) { throw :failure },
          cast_double,
        ]

        result = chain.call("foo", messenger)

        expect(result).to eq(Failure())
      end
    end

    context "when a cast throws :failure with a value" do
      it "halts the chain, adds a <value> message as an error and returns Failure()" do
        chain = described_class.new [
          ->(value, _messenger) { value.capitalize },
          ->(_value, _messenger) { throw :failure, "some_code" },
          cast_double,
        ]

        allow(messenger).to receive(:error)

        result = chain.call("foo", messenger)

        expect(result).to eq(Failure())
        expect(messenger).to have_received(:error).with("some_code")
      end
    end
  end
end
