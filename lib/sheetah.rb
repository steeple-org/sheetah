# frozen_string_literal: true

# {Sheetah} is a library designed to process tabular data according to a
# {Sheetah::Template developer-defined structure}. It will turn each row into a
# object whose keys and types are specified by the structure.
#
# It can work with tabular data presented in different formats by delegating
# the parsing of documents to specialized backends
# ({Sheetah::Backends::Xlsx}, {Sheetah::Backends::Csv}, etc...).
#
# Given a tabular document and a specification of the document structure,
# Sheetah may process the document by handling the following tasks:
#
# - validation of the document's actual structure
# - arbitrary complex typecasting of each row into a validated object,
#   according to the document specification
# - fine-grained error handling (at the sheet/row/col/cell level)
# - all of the above done so that internationalization of messages is easy
#
# Sheetah is designed with memory efficiency in mind by processing documents
# one row at a time, thus not requiring parsing and loading the whole document
# in memory upfront (depending on the backend). The memory consumption of the
# library should therefore theoretically stay stable during the processing of a
# document, disregarding how many rows it may have.
module Sheetah
end

require "sheetah/template"
require "sheetah/template_config"
require "sheetah/sheet_processor"
require "sheetah/backends/wrapper"
