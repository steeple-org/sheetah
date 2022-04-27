# frozen_string_literal: true

require "sheetah/errors/error"

RSpec.describe Sheetah::Errors::Error do
  it "is some kind of StandardError" do
    expect(described_class.superclass).to be(StandardError)
  end

  describe "class msg_code" do
    it "has a msg_code" do
      expect(described_class.msg_code).to eq("sheetah.errors.error")
    end

    context "when inherited" do
      context "when first defined anonymously" do
        let(:subclass) do
          Class.new(described_class)
        end

        context "when kept anonymous" do
          it "doesn't have a msg_code by default" do
            expect(subclass.msg_code).to be_nil
          end

          it "cannot deduce a msg_code" do
            expect do
              subclass.msg_code!
            end.to raise_error(TypeError, /cannot build msg_code/i)
          end

          it "may have a custom msg_code" do
            subclass.msg_code! "foo.bar.baz"
            expect(subclass.msg_code).to eq("foo.bar.baz")
          end
        end

        context "when named afterwards" do
          before do
            stub_const("Foizjeofijow::OIJDFO834", subclass)
          end

          it "doesn't have a msg_code by default" do
            expect(subclass.msg_code).to be_nil
          end

          it "can deduce a msg_code" do
            subclass.msg_code!
            expect(subclass.msg_code).to eq("foizjeofijow.oijdfo834")
          end

          it "may have a custom msg_code" do
            subclass.msg_code! "foo.bar.baz"
            expect(subclass.msg_code).to eq("foo.bar.baz")
          end
        end
      end

      context "when first defined with a name" do
        let(:namespace) { Module.new }

        let(:subclass) do
          class namespace::OIJDFO834 < described_class # rubocop:disable RSpec/LeakyConstantDeclaration,Lint/ConstantDefinitionInBlock,Style/ClassAndModuleChildren
            self
          end
        end

        context "when fully named" do
          before do
            stub_const("Foizjeofijow", namespace)
          end

          it "has a msg_code by default" do
            expect(subclass.msg_code).to eq("foizjeofijow.oijdfo834")
          end

          it "can deduce the same msg_code" do
            expect do
              subclass.msg_code!
            end.not_to change(subclass, :msg_code)
          end

          it "may have a custom msg_code" do
            subclass.msg_code! "foo.bar.baz"
            expect(subclass.msg_code).to eq("foo.bar.baz")
          end
        end

        context "when not fully named" do
          it "doesn't have a msg_code by default" do
            expect(subclass.msg_code).to be_nil
          end

          it "cannot deduce a msg_code" do
            expect do
              subclass.msg_code!
            end.to raise_error(TypeError, /cannot build msg_code/i)
          end

          it "may have a custom msg_code" do
            subclass.msg_code! "foo.bar.baz"
            expect(subclass.msg_code).to eq("foo.bar.baz")
          end
        end
      end
    end
  end

  describe "#msg_code" do
    it "delegates to the class" do
      allow(described_class).to receive(:msg_code).and_return(msg_code = double)
      expect(subject.msg_code).to be(msg_code)
    end
  end
end
