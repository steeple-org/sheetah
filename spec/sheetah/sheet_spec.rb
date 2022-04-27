# frozen_string_literal: true

require "sheetah/sheet"

RSpec.describe Sheetah::Sheet, monadic_result: true do
  let(:sheet_class) do
    c = Class.new do
      def initialize(foo, bar:)
        @foo = foo
        @bar = bar
      end
    end

    c.include(described_class)

    stub_const("SheetClass", c)

    c
  end

  let(:sheet) do
    sheet_class.new(foo, bar: bar)
  end

  let(:foo) { double }
  let(:bar) { double }

  describe "::Error" do
    subject { sheet_class::Error }

    it "exposes some kind of Sheetah::Errors::Error" do
      expect(subject.superclass).to be(Sheetah::Errors::Error)
    end
  end

  describe "::Header" do
    let(:col) { double }
    let(:val) { double }

    let(:wrapper) { sheet_class::Header.new(col: col, value: val) }

    it "exposes a header wrapper" do
      expect(wrapper).to have_attributes(col: col, value: val)
    end

    it "is comparable" do
      expect(wrapper).to eq(sheet_class::Header.new(col: col, value: val))
      expect(wrapper).not_to eq(sheet_class::Header.new(col: double, value: val))
    end
  end

  describe "::Row" do
    let(:row) { double }
    let(:val) { double }

    let(:wrapper) { sheet_class::Row.new(row: row, value: val) }

    it "exposes a row wrapper" do
      expect(wrapper).to have_attributes(row: row, value: val)
    end

    it "is comparable" do
      expect(wrapper).to eq(sheet_class::Row.new(row: row, value: val))
      expect(wrapper).not_to eq(sheet_class::Row.new(row: double, value: val))
    end
  end

  describe "::Cell" do
    let(:row) { double }
    let(:col) { double }
    let(:val) { double }

    let(:wrapper) { sheet_class::Cell.new(row: row, col: col, value: val) }

    it "exposes a row wrapper" do
      expect(wrapper).to have_attributes(row: row, col: col, value: val)
    end

    it "is comparable" do
      expect(wrapper).to eq(sheet_class::Cell.new(row: row, col: col, value: val))
      expect(wrapper).not_to eq(sheet_class::Cell.new(row: double, col: col, value: val))
    end
  end

  describe "singleton class methods" do
    let(:samples) do
      [
        ["A", 1],
        ["B", 2],
        ["Z", 26],
        ["AA", 27],
        ["AZ", 52],
        ["BA", 53],
        ["ZA", 677],
        ["ZZ", 702],
        ["AAA", 703],
        ["AAZ", 728],
        ["ABA", 729],
        ["BZA", 2029],
      ]
    end

    describe "::col2int" do
      it "turns letter-based indexes into integer-based indexes" do
        samples.each do |(col, int)|
          res = described_class.col2int(col)
          expect(res).to eq(int), "Expected #{col} => #{int}, got: #{res}"
        end
      end

      it "fails on invalid inputs" do
        expect { described_class.col2int(nil) }.to raise_error(ArgumentError)
        expect { described_class.col2int("") }.to raise_error(ArgumentError)
        expect { described_class.col2int("a") }.to raise_error(ArgumentError)
        expect { described_class.col2int("€") }.to raise_error(ArgumentError)
      end
    end

    describe "::int2col" do
      it "turns integer-based indexes into letter-based indexes" do
        samples.each do |(col, int)|
          res = described_class.int2col(int)
          expect(res).to eq(col), "Expected #{int} => #{col}, got: #{res}"
        end
      end

      it "fails on invalid inputs" do
        expect { described_class.int2col(nil) }.to raise_error(ArgumentError)
        expect { described_class.int2col(0) }.to raise_error(ArgumentError)
        expect { described_class.int2col(-12) }.to raise_error(ArgumentError)
        expect { described_class.int2col(27.0) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "::open" do
    let(:sheet) do
      instance_double(sheet_class)
    end

    before do
      allow(sheet_class).to receive(:new).with(foo, bar: bar).and_return(sheet)
    end

    context "without a block" do
      it "returns a new sheet wrapped as a Success" do
        expect(sheet_class.open(foo, bar: bar)).to eq(Success(sheet))
      end
    end

    context "with a block" do
      before do
        allow(sheet).to receive(:close)
      end

      it "yields a new sheet" do
        yielded = false

        sheet_class.open(foo, bar: bar) do |opened_sheet|
          yielded = true
          expect(opened_sheet).to be(sheet)
        end

        expect(yielded).to be(true)
      end

      it "returns the value of the block, wrapped as a success" do
        block_result = double
        actual_block_result = sheet_class.open(foo, bar: bar) { block_result }

        expect(actual_block_result).to eq(Success(block_result))
      end

      it "closes after yielding" do
        sheet_class.open(foo, bar: bar) do
          expect(sheet).not_to have_received(:close)
        end

        expect(sheet).to have_received(:close)
      end

      context "when an exception is raised" do
        let(:exception)   { Class.new(Exception) } # rubocop:disable Lint/InheritException
        let(:error)       { Class.new(StandardError) }
        let(:sheet_error) { Class.new(Sheetah::Sheet::Error) }

        context "without yielding control" do
          it "doesn't rescue an exception" do
            allow(sheet_class).to receive(:new).and_raise(exception)

            expect do
              sheet_class.open(foo, bar: bar)
            end.to raise_error(exception)
          end

          it "doesn't rescue a standard error" do
            allow(sheet_class).to receive(:new).and_raise(error)

            expect do
              sheet_class.open(foo, bar: bar)
            end.to raise_error(error)
          end

          it "rescues and wraps a sheet error in a failure" do
            allow(sheet_class).to receive(:new).and_raise(e = sheet_error.exception)

            result = sheet_class.open(foo, bar: bar)

            expect(result).to eq(Failure(e))
          end
        end

        context "while yielding control" do
          it "doesn't rescue but closes after an exception is raised" do
            expect do
              sheet_class.open(foo, bar: bar) do
                expect(sheet).not_to have_received(:close)
                raise exception
              end
            end.to raise_error(exception)

            expect(sheet).to have_received(:close)
          end

          it "doesn't rescue but closes after a standard error is raised" do
            expect do
              sheet_class.open(foo, bar: bar) do
                expect(sheet).not_to have_received(:close)
                raise error
              end
            end.to raise_error(error)

            expect(sheet).to have_received(:close)
          end

          it "rescues and closes after a sheet error is raised" do
            sheet_class.open(foo, bar: bar) do
              expect(sheet).not_to have_received(:close)
              raise sheet_error
            end

            expect(sheet).to have_received(:close)
          end

          it "returns the exception, wrapped as a failure, after a sheet error is raised" do
            e = sheet_error.exception # raise the instance directly to simplify result matching

            result = sheet_class.open(foo, bar: bar) do
              raise e
            end

            expect(result).to eq(Failure(e))
          end
        end
      end
    end
  end

  describe "#each_header" do
    it "is abstract" do
      expect { sheet.each_header }.to raise_error(
        NoMethodError, "You must implement SheetClass#each_header => self"
      )
    end
  end

  describe "#each_row" do
    it "is abstract" do
      expect { sheet.each_row }.to raise_error(
        NoMethodError, "You must implement SheetClass#each_row => self"
      )
    end
  end

  describe "#close" do
    it "is abstract" do
      expect { sheet.close }.to raise_error(
        NoMethodError, "You must implement SheetClass#close => nil"
      )
    end
  end
end
