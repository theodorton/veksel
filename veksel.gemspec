require_relative "lib/veksel/version"

Gem::Specification.new do |spec|
  spec.name        = "veksel"
  spec.version     = Veksel::VERSION
  spec.authors     = ["Theodor Tonum"]
  spec.email       = ["theodor@tonum.no"]
  spec.homepage    = "https://github.com/theodorton/veksel"
  spec.summary     = "Veksel keeps seperate databases for every branch in your development environment. This makes it easy to experiment with schema changes and data with less risk and schema.rb headache when switching branches that has different sets of migrations. The inspiration for the gem came from neons branch support."
  spec.description = "Seperate databases for every branch in your development environment"
  spec.license     = "MIT"

  spec.metadata["allowed_push_host"] = 'https://rubygems.org'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/theodorton/veksel"
  spec.metadata["changelog_uri"] = "https://github.com/theodorton/veksel/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{lib}/**/*", "LICENSE.md", "Rakefile", "README.md"]
  end

  spec.executables << 'veksel'

  spec.add_dependency "rails", ">= 6", "< 8"
  spec.add_dependency "activerecord"
  spec.add_dependency "pg"

  spec.add_development_dependency "appraisal"
end
