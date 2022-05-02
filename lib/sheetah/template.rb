# frozen_string_literal: true

require "set"
require_relative "attribute"
require_relative "specification"
require_relative "errors/spec_error"

module Sheetah
  # A {Template} represents the abstract structure of a tabular document.
  #
  # The main component of the structure is the object obtained by processing a
  # row. A template therefore specifies all possible attributes of that object
  # as a list of (key, abstract type) pairs.
  #
  # Each attribute will eventually be compiled into as many concrete columns as
  # necessary with the help of a {TemplateConfig config} to produce a
  # {Specification specification}.
  #
  # In other words, a {Template} specifies the structure of the processing
  # result (its attributes), whereas a {Specification} specifies the columns
  # that may be involved into building the processing result.
  #
  # {Attribute Attributes} may either be _composite_ (their value is a
  # composition of multiple values) or _scalar_ (their value is a single
  # value). Scalar attributes will thus produce a single column in the
  # specification, and composite attributes will produce as many columns as
  # required by the number of scalar values they hold.
  class Template
    def initialize(attributes:, ignore_unspecified_columns: false)
      @attributes = build_attributes(attributes)
      @ignore_unspecified_columns = ignore_unspecified_columns
    end

    def apply(config)
      specification = Specification.new(ignore_unspecified_columns: @ignore_unspecified_columns)

      @attributes.each do |attribute|
        attribute.each_column(config) do |column|
          specification.set(column.header_pattern, column)
        end
      end

      specification.freeze
    end

    private

    def build_attributes(attributes)
      uniq_keys = Set.new

      uniq_attributes = attributes.map do |kwargs|
        attribute = Attribute.new(**kwargs)

        unless uniq_keys.add?(attribute.key)
          raise Errors::SpecError, "Duplicated key: #{attribute.key.inspect}"
        end

        attribute
      end

      uniq_attributes.freeze
    end
  end
end
