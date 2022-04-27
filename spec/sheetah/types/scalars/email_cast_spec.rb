# frozen_string_literal: true

require "sheetah/types/scalars/email_cast"
require "sheetah/messaging"
require "support/shared/cast_class"

RSpec.describe Sheetah::Types::Scalars::EmailCast do
  it_behaves_like "cast_class"

  describe "#initialize" do
    it "setups a default, conventional e-mail matcher" do
      expect(described_class.new).to eq(
        described_class.new(email_matcher: URI::MailTo::EMAIL_REGEXP)
      )
    end
  end

  describe "#call" do
    subject(:cast) { described_class.new(email_matcher: email_matcher) }

    let(:email_matcher) do
      instance_double(Regexp)
    end

    let(:value) { instance_double(Object, inspect: double) }
    let(:messenger) { instance_double(Sheetah::Messaging::Messenger) }

    before do
      allow(email_matcher).to receive(:match?).with(value).and_return(value_is_email)
    end

    context "when the value is an email address" do
      let(:value_is_email) { true }

      it "returns the value" do
        expect(cast.call(value, messenger)).to eq(value)
      end
    end

    context "when the value isn't an email address" do
      let(:value_is_email) { false }

      it "adds an error message and throws :failure" do
        expect(messenger).to receive(:error).with("must_be_email", value: value.inspect)
        expect { cast.call(value, messenger) }.to throw_symbol(:failure, nil)
      end
    end
  end
end
