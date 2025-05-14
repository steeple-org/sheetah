# frozen_string_literal: true

require "sheetah"

RSpec.describe Sheetah, monadic_result: true do
  let(:types) do
    reverse_string = Sheetah::Types::Scalars::String.cast { |v, _m| v.reverse }

    Sheetah::Types::Container.new(
      scalars: {
        reverse_string: reverse_string.method(:new),
      }
    )
  end

  let(:template_opts) do
    {
      attributes: [
        {
          key: :foo,
          type: :reverse_string!,
        },
        {
          key: :bar,
          type: {
            composite: :array,
            scalars: %i[
              string
              scalar
              email
              scalar
              scalar!
            ],
          },
        },
      ],
    }
  end

  let(:template) do
    Sheetah::Template.new(**template_opts)
  end

  let(:template_config) do
    Sheetah::TemplateConfig.new(types: types)
  end

  let(:specification) do
    template.apply(template_config)
  end

  let(:processor) do
    Sheetah::SheetProcessor.new(specification)
  end

  let(:input) do
    [
      ["foo", "bar 3", "bar 5", "bar 1"],
      ["hello", "foo@bar.baz", Float, nil],
      ["world", "foo@bar.baz", Float, nil],
      ["world", "boudiou !", Float, nil],
    ]
  end

  def process(*args, **opts, &block)
    processor.call(*args, backend: Sheetah::Backends::Wrapper, **opts, &block)
  end

  def process_to_a(*args, **opts)
    a = []
    processor.call(*args, backend: Sheetah::Backends::Wrapper, **opts) { |result| a << result }
    a
  end

  context "when there is no sheet error" do
    it "is a success without errors" do
      result = process(input) {}

      expect(result).to have_attributes(result: Success(), messages: [])
    end

    it "yields a commented result for each valid and invalid row" do
      results = process_to_a(input)

      expect(results).to have_attributes(size: 3)
      expect(results[0]).to have_attributes(result: be_success, messages: be_empty)
      expect(results[1]).to have_attributes(result: be_success, messages: be_empty)
      expect(results[2]).to have_attributes(result: be_failure, messages: have_attributes(size: 1))
    end

    it "yields the successful value for each valid row" do
      results = process_to_a(input)

      expect(results[0].result).to eq(
        Success(foo: "olleh", bar: [nil, nil, "foo@bar.baz", nil, Float])
      )

      expect(results[1].result).to eq(
        Success(foo: "dlrow", bar: [nil, nil, "foo@bar.baz", nil, Float])
      )
    end

    it "yields the failure data for each invalid row" do
      results = process_to_a(input)

      expect(results[2].result).to eq(Failure())
      expect(results[2].messages).to contain_exactly(
        have_attributes(
          code: "must_be_email",
          code_data: { value: "boudiou !".inspect },
          scope: Sheetah::Messaging::SCOPES::CELL,
          scope_data: { row: 3, col: "B" },
          severity: Sheetah::Messaging::SEVERITIES::ERROR
        )
      )
    end
  end

  context "when there are unspecified columns in the sheet" do
    before do
      input.each_index do |idx|
        input[idx] = input[idx][0..1] + ["oof"] + input[idx][2..] + ["rab"]
      end
    end

    context "when the template allows it" do
      before { template_opts[:ignore_unspecified_columns] = true }

      it "ignores the unspecified columns" do
        results = process_to_a(input)

        expect(results[0].result).to eq(
          Success(foo: "olleh", bar: [nil, nil, "foo@bar.baz", nil, Float])
        )

        expect(results[1].result).to eq(
          Success(foo: "dlrow", bar: [nil, nil, "foo@bar.baz", nil, Float])
        )
      end

      context "when the reporting is enabled" do
        before { template_opts[:report_ignored_columns] = true }

        it "messages the ignored columns" do # rubocop:disable RSpec/ExampleLength
          expect(process(input) {}).to have_attributes(
            result: Success(),
            messages: contain_exactly(
              have_attributes(
                code: "ignored_column",
                code_data: "oof",
                scope: Sheetah::Messaging::SCOPES::COL,
                scope_data: { col: "C" },
                severity: Sheetah::Messaging::SEVERITIES::WARN
              ),
              have_attributes(
                code: "ignored_column",
                code_data: "rab",
                scope: Sheetah::Messaging::SCOPES::COL,
                scope_data: { col: "F" },
                severity: Sheetah::Messaging::SEVERITIES::WARN
              )
            )
          )
        end
      end
    end

    context "when the template doesn't allow it" do
      before { template_opts[:ignore_unspecified_columns] = false }

      it "doesn't yield any row" do
        expect { |b| process(input, &b) }.not_to yield_control
      end

      it "returns a failure with data" do # rubocop:disable RSpec/ExampleLength
        expect(process(input) {}).to have_attributes(
          result: Failure(),
          messages: contain_exactly(
            have_attributes(
              code: "invalid_header",
              code_data: "oof",
              scope: Sheetah::Messaging::SCOPES::COL,
              scope_data: { col: "C" },
              severity: Sheetah::Messaging::SEVERITIES::ERROR
            ),
            have_attributes(
              code: "invalid_header",
              code_data: "rab",
              scope: Sheetah::Messaging::SCOPES::COL,
              scope_data: { col: "F" },
              severity: Sheetah::Messaging::SEVERITIES::ERROR
            )
          )
        )
      end
    end
  end

  context "when there are missing columns" do
    before do
      input.each do |input|
        input.delete_at(2)
        input.delete_at(0)
      end
    end

    it "doesn't yield any row" do
      expect { |b| process(input, &b) }.not_to yield_control
    end

    it "returns a failure with data" do # rubocop:disable RSpec/ExampleLength
      expect(process(input) {}).to have_attributes(
        result: Failure(),
        messages: contain_exactly(
          have_attributes(
            code: "missing_column",
            code_data: "Foo",
            scope: Sheetah::Messaging::SCOPES::SHEET,
            scope_data: nil,
            severity: Sheetah::Messaging::SEVERITIES::ERROR
          ),
          have_attributes(
            code: "missing_column",
            code_data: "Bar 5",
            scope: Sheetah::Messaging::SCOPES::SHEET,
            scope_data: nil,
            severity: Sheetah::Messaging::SEVERITIES::ERROR
          )
        )
      )
    end
  end
end
