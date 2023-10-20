# frozen_string_literal: true

require "sheetah/types/scalars/scalar_cast"
require "sheetah/messaging"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Scalars::ScalarCast do
  it_behaves_like "cast_class"

  describe "#call" do
    subject(:cast) { described_class.new }

    let(:messenger) do
      instance_double(Sheetah::Messaging::Messenger)
    end

    context "when given nil" do
      context "when nullable" do
        subject(:cast) { described_class.new(nullable: true) }

        it "halts with a success and nil as value" do
          expect do
            cast.call(nil, messenger)
          end.to throw_symbol(:success, nil)
        end
      end

      context "when non-nullable" do
        subject(:cast) { described_class.new(nullable: false) }

        it "halts with a failure and an appropriate error code" do
          expect do
            cast.call(nil, messenger)
          end.to throw_symbol(
            :failure, Sheetah::Messaging::Messages::MustExist.new
          )
        end
      end
    end

    context "when given a String" do
      let(:string_with_garbage)    { " string_foo	" }
      let(:string_without_garbage) { "string_foo" }

      before do
        allow(messenger).to receive(:warn)
      end

      context "when cleaning strings" do
        subject(:cast) do
          described_class.new(clean_string: true)
        end

        context "when string contains garbage" do
          it "removes garbage around the value and warns about it" do
            value = cast.call(string_with_garbage, messenger)

            expect(value).to eq(string_without_garbage)
            expect(messenger).to have_received(:warn)
              .with(Sheetah::Messaging::Messages::CleanedString.new)
          end
        end

        context "when string doesn't contain garbage" do
          it "returns the string as is" do
            value = cast.call(string_without_garbage, messenger)

            expect(value).to eq(string_without_garbage)
            expect(messenger).not_to have_received(:warn)
          end
        end
      end

      context "when not cleaning strings" do
        subject(:cast) do
          described_class.new(clean_string: false)
        end

        context "when string contains garbage" do
          it "returns the string as is" do
            value = cast.call(string_with_garbage, messenger)

            expect(value).to eq(string_with_garbage)
            expect(messenger).not_to have_received(:warn)
          end
        end

        context "when string doesn't contain garbage" do
          it "returns the string as is" do
            value = cast.call(string_without_garbage, messenger)

            expect(value).to eq(string_without_garbage)
            expect(messenger).not_to have_received(:warn)
          end
        end
      end
    end

    context "when given something else" do
      it "returns the string as is" do
        something_else = double

        value = cast.call(something_else, messenger)

        expect(value).to eq(something_else)
      end
    end
  end
end
