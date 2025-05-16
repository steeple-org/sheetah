# frozen_string_literal: true

require "sheetah/types/type"

RSpec.describe Sheetah::Types::Type do
  describe "class API" do
    let(:klass0) { Class.new(described_class) }
    let(:klass1) { Class.new(klass0) }
    let(:klass2) { Class.new(klass1) }

    describe "::all" do
      it "returns an enumerator for self and known descendant types" do
        enum = klass0.all
        expect(enum).to be_a(Enumerator) & contain_exactly(klass0)

        klass1
        klass2
        expect(klass0.all.to_a).to contain_exactly(klass0, klass1, klass2)
        expect(klass1.all.to_a).to contain_exactly(klass1, klass2)
      end
    end

    describe "::cast_classes" do
      it "is an empty array" do
        expect(described_class.cast_classes).to eq([])
      end

      it "is inheritable" do
        expect([klass0, klass1, klass2]).to all(
          have_attributes(cast_classes: described_class.cast_classes)
        )
      end
    end

    describe "::cast_classes=" do
      let(:cast_classes0) { [double, double] }
      let(:cast_classes1) { [double, double] }

      it "mutates the class instance" do
        klass0.cast_classes = cast_classes0
        expect(klass0).to have_attributes(cast_classes: cast_classes0)
      end

      it "applies to the inherited children" do
        klass0.cast_classes = cast_classes0
        expect([klass0, klass1, klass2].map(&:cast_classes)).to eq(
          [cast_classes0, cast_classes0, cast_classes0]
        )
      end

      it "doesn't apply to the children mutated afterwards" do
        klass0.cast_classes = cast_classes0
        klass1.cast_classes = cast_classes1
        expect([klass0, klass1, klass2].map(&:cast_classes)).to eq(
          [cast_classes0, cast_classes1, cast_classes1]
        )
      end

      it "doesn't apply to the children mutated beforehand" do
        klass1.cast_classes = cast_classes1
        klass0.cast_classes = cast_classes0
        expect([klass0, klass1, klass2].map(&:cast_classes)).to eq(
          [cast_classes0, cast_classes1, cast_classes1]
        )
      end
    end

    describe "::freeze" do
      it "freezes the instance and its cast classes" do
        klass1.freeze
        expect([klass1, klass1.cast_classes]).to all(be_frozen)
      end

      it "doesn't freeze a warm superclass nor its cast classes" do
        klass1.freeze
        expect([klass0, klass0.cast_classes]).not_to include(be_frozen)
      end

      it "doesn't freeze a warm subclass nor its *own* cast classes" do
        klass0.freeze
        expect(klass1).not_to be_frozen
        expect(klass1.cast_classes).to be_frozen

        klass1.cast_classes += [double]
        expect(klass1.cast_classes).not_to be_frozen
      end
    end

    describe "::cast" do
      let(:cast_class0) { double }
      let(:cast_class1) { double }

      before do
        klass0.cast_classes = [cast_class0]
        klass0.freeze
      end

      context "when given a class" do
        it "creates a new type appending the given cast" do
          type_class = klass0.cast(cast_class1)

          expect(type_class).to have_attributes(
            class: Class,
            superclass: klass0,
            cast_classes: [cast_class0, cast_class1]
          )
        end
      end

      context "when given a block" do
        let(:cast) { -> {} }
        let(:type_class) { klass0.cast(&cast) }

        it "creates a new type appending the given cast" do
          expect(type_class).to have_attributes(
            class: Class,
            superclass: klass0,
            cast_classes: [cast_class0, described_class::SimpleCast.new(cast)]
          )
        end

        it "still behaves as a cast class" do
          block_cast_class = type_class.cast_classes.last

          expect(block_cast_class.new(foo: :bar)).to be(cast)
        end
      end

      context "when given both a class and a block" do
        it "raises an error" do
          expect { described_class.cast(cast_class0) { double } }.to raise_error(
            ArgumentError, "Expected either a Class or a block, got both"
          )
        end
      end

      context "when given neither a class nor a block" do
        it "raises an error" do
          expect { described_class.cast }.to raise_error(
            ArgumentError, "Expected either a Class or a block, got none"
          )
        end
      end
    end

    describe "::new!" do
      it "initializes a new, frozen type" do
        type = described_class.new!
        expect(type).to be_a(described_class) & be_frozen
      end
    end
  end

  describe "instance API" do
    describe "#initialize" do
      let(:cast_class0) do
        instance_double(Class)
      end

      let(:cast_class1) do
        instance_double(Class)
      end

      let(:cast_block) do
        -> {}
      end

      let(:type_class) do
        klass = described_class.cast(&cast_block)
        klass.cast_classes << cast_class0
        klass.cast_classes << cast_class1
        klass
      end

      def stub_new_casts(opts)
        type_class.cast_classes.map do |cast_class|
          allow(cast_class).to receive(:new).with(**opts).and_return(cast = double)
          cast
        end
      end

      it "builds a cast chain of all casts initialized with the opts" do
        opts = { foo: :bar, hello: "world" }

        casts = stub_new_casts(opts)

        type = type_class.new(**opts)

        expect(type.cast_chain).to(
          be_a(Sheetah::Types::CastChain) &
          have_attributes(casts:)
        )
      end
    end

    describe "#cast" do
      it "delegates the task to the cast chain" do
        type = described_class.new
        value = double
        messenger = double
        result = double

        expect(type.cast_chain).to receive(:call).with(value, messenger).and_return(result)
        expect(type.cast(value, messenger)).to be(result)
      end
    end

    describe "#freeze" do
      it "freezes self and the cast chain" do
        type = described_class.new
        type.freeze

        expect(type).to be_frozen
        expect(type.cast_chain).to be_frozen
      end
    end

    describe "abstract API" do
      let(:type) { described_class.new }

      def raise_abstract_method_error
        raise_error(NoMethodError, /you must implement this method/i)
      end

      describe "#scalar?" do
        it "is abstract" do
          expect { type.scalar? }.to raise_abstract_method_error
        end
      end

      describe "#composite?" do
        it "is abstract" do
          expect { type.composite? }.to raise_abstract_method_error
        end
      end

      describe "#scalar" do
        it "is abstract" do
          expect { type.scalar(double, double, double) }.to raise_abstract_method_error
        end
      end

      describe "#composite" do
        it "is abstract" do
          expect { type.composite(double, double) }.to raise_abstract_method_error
        end
      end
    end
  end
end
