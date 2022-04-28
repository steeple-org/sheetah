# frozen_string_literal: true

require "sheetah/types/container"

RSpec.describe Sheetah::Types::Container do
  let(:default_scalars) do
    %i[scalar string email boolsy date_string]
  end

  let(:default_composites) do
    %i[array array_compact]
  end

  context "when used by default" do
    subject(:container) { described_class.new }

    it "knows about some types" do
      expect(container.scalars).to match_array(default_scalars)
      expect(container.composites).to match_array(default_composites)
    end

    describe "typemap" do
      let(:scalar_type) do
        Sheetah::Types::Scalars::Scalar
      end

      let(:string_type) do
        Sheetah::Types::Scalars::String
      end

      let(:email_type) do
        Sheetah::Types::Scalars::Email
      end

      let(:boolsy_type) do
        Sheetah::Types::Scalars::Boolsy
      end

      let(:date_string_type) do
        Sheetah::Types::Scalars::DateString
      end

      def stub_new_type(klass, *args)
        args << no_args if args.empty?
        allow(klass).to receive(:new!).with(*args).and_return(instance = double)
        instance
      end

      it "is readable" do
        expect(described_class::DEFAULTS).to match(
          scalars: include(*default_scalars) & be_frozen,
          composites: include(*default_composites) & be_frozen
        ) & be_frozen
      end

      example "scalars: scalar" do
        expect(scalar = container.scalar(:scalar)).to be_a(scalar_type) & be_frozen
        expect(container.scalar(:scalar)).to be(scalar)
      end

      example "scalars: string" do
        expect(string = container.scalar(:string)).to be_a(string_type) & be_frozen
        expect(container.scalar(:string)).to be(string)
      end

      example "scalars: email" do
        expect(email = container.scalar(:email)).to be_a(email_type) & be_frozen
        expect(container.scalar(:email)).to be(email)
      end

      example "scalars: boolsy" do
        expect(boolsy = container.scalar(:boolsy)).to be_a(boolsy_type) & be_frozen
        expect(container.scalar(:boolsy)).to be(boolsy)
      end

      example "scalars: date_string" do
        expect(date_string = container.scalar(:date_string)).to be_a(date_string_type) & be_frozen
        expect(container.scalar(:date_string)).to be(date_string)
      end

      example "composites: array" do
        type = stub_new_type(Sheetah::Types::Composites::Array, [string_type, email_type])
        expect(container.composite(:array, %i[string email])).to be(type)
      end

      example "composites: array_composite" do
        type = stub_new_type(Sheetah::Types::Composites::ArrayCompact, [string_type, email_type])
        expect(container.composite(:array_compact, %i[string email])).to be(type)
      end
    end
  end

  context "when extended" do
    let(:foo_type) { double }
    let(:bar_type) { double }
    let(:baz_type) { double }
    let(:oof_type) { double }

    let(:container) do
      described_class.new(
        scalars: {
          foo: -> { foo_type },
          string: -> { bar_type },
        },
        composites: {
          baz: ->(_types) { baz_type },
          array: ->(_types) { oof_type },
        }
      )
    end

    it "can use custom scalars and composites" do
      expect(container.scalars).to contain_exactly(*default_scalars, :foo)
      expect(container.scalar(:foo)).to be(foo_type)
      expect(container.composites).to contain_exactly(*default_composites, :baz)
      expect(container.composite(:baz, %i[foo])).to be(baz_type)
    end

    it "can override default type definitions" do
      expect(container.scalar(:string)).to be(bar_type)
      expect(container.composite(:array, %i[foo])).to be(oof_type)
    end

    it "can override the default type map" do
      container = described_class.new(
        defaults: {
          scalars: { foo: -> { foo_type } },
          composites: { bar: ->(_types) { bar_type } },
        }
      )

      expect(container.scalars).to contain_exactly(:foo)
      expect(container.scalar(:foo)).to be(foo_type)
      expect(container.composites).to contain_exactly(:bar)
      expect(container.composite(:bar, %i[foo])).to be(bar_type)
    end
  end

  context "when a scalar definition doesn't exist" do
    it "raises an error when used as a scalar" do
      expect { subject.scalar(:foo) }.to raise_error(
        Sheetah::Errors::TypeError,
        "Invalid scalar type: :foo"
      )
    end

    it "raises an error when used in a composite" do
      expect { subject.composite(:array, [:foo]) }.to raise_error(
        Sheetah::Errors::TypeError,
        "Invalid scalar type: :foo"
      )
    end
  end

  context "when a composite definition doesn't exist" do
    it "raises an error" do
      expect { subject.composite(:foo, []) }.to raise_error(
        Sheetah::Errors::TypeError,
        "Invalid composite type: :foo"
      )
    end
  end
end
