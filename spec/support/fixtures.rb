# frozen_string_literal: true

mod = Module.new do
  def fixtures_path
    @fixtures_path ||= File.expand_path("./fixtures", __dir__)
  end

  def fixture_path(path)
    File.join(fixtures_path, path)
  end
end

RSpec.configure do |config|
  config.include(mod)
end
