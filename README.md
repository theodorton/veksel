[![Gem Version](https://badge.fury.io/rb/veksel.svg)](https://rubygems.org/gems/veksel)
[![Build status](https://github.com/theodorton/veksel/actions/workflows/test.yml/badge.svg?branch=main&event=push)](https://github.com/theodorton/veksel/actions?query=event%3Apush+branch%3Amain)

# Veksel: Database branching for Rails

Veksel keeps seperate databases for every branch in your development environment. This makes it easy to experiment with schema changes and data with less risk and avoid conflicting changes to `schema.rb` when branches have different sets of migrations. The inspiration for the gem came from [branch support in Neon](https://neon.tech/docs/manage/branches).

Postgresql is currently the only supported database driver.

## Usage

Out of the box, Veksel requires explicit invocation to work. Refer to [Git hook](#git-hook) below if you're interested in a more automated approach.

Checkout a new branch and run `bundle exec veksel fork`. A new database with a suffix matching your branch name will be created and `tmp/restart.txt` will be touched so your application servers restart. Both database structure and contents will be copied from your primary development database and Veksel will tell Rails on boot that the forked database should be used.

When moving back to your `main` branch, run `touch tmp/restart.txt` to make Rails connect to default development database.

### Veksel tasks

The CLI supports the following commands

```
veksel fork                        Create a forked database
veksel clean                       Delete forked databases
veksel fork                        Fork the database from the main branch
veksel list                        List forked databases
```

You can also run the commands as rake tasks (e.g. `bin/rails veksel:list`), albeit with a penalty hit.

## Git hook

Add the following to `.git/hooks/post-checkout` to automatically fork your database when checking out a branch:

```
#!/bin/sh
bundle exec veksel fork
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "veksel", group: :development
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

## Release process

```shell
# Bump version number in lib/veksel/version.rb

# Update lockfile
bundle install

# Update changelog, review manually before committing
conventional-changelog -p conventionalcommits -i CHANGELOG.md -s
git commit -m 'chore(release): x.y.z'
git push origin
git tag vx.y.z
git push origin vx.y.z

# Build and push gem
gem build
gem push veksel-x.y.z.gem

# Upload the veksel-x-y-z.gem file to the Github release page
```

## Sponsors

Veksel is sponsored by [Skalar](https://github.com/Skalar)

## License

Veksel is licensed under MIT.
