[![Gem Version](https://badge.fury.io/rb/veksel.svg)](https://rubygems.org/gems/veksel)
[![Build status](https://github.com/theodorton/veksel/actions/workflows/test.yml/badge.svg?branch=main&event=push)](https://github.com/theodorton/veksel/actions?query=event%3Apush+branch%3Amain)

# Veksel: Database branching for Rails

Veksel keeps seperate databases for every branch in your development environment. This makes it easy to experiment with schema changes and data with less risk and avoid conflicting changes to `schema.rb` when branches have different sets of migrations. The inspiration for the gem came from [branch support in Neon](https://neon.tech/docs/manage/branches).

Postgresql is currently the only supported database driver.

## Usage

Change the following line in `config/database.yml`

```yaml
development:
  database: your_app_development<%= `bundle exec veksel suffix` %>
```

Checkout a new branch and run `bin/rails veksel:fork`. A new database with a suffix matching your branch name will be created.

### Veksel tasks

```
veksel:clean                       Delete forked databases
veksel:fork                        Fork the database from the main branch
veksel:list                        List forked databases
```

## Git hook

Add the following to `.git/hooks/post-checkout` to automatically fork your database when checking out a branch:

```
#!/bin/sh
bin/rails veksel:fork
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "veksel"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install veksel
```

## Roadmap

- Promote a forked database to main
- Explicit/optional branching
- Other database drivers

## Sponsors

Veksel is sponsored by [Skalar](https://github.com/Skalar)

## License

Veksel is licensed under MIT.
