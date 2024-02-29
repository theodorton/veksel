ARG RUBY_VERSION=3.2.3
FROM ruby:${RUBY_VERSION}

RUN apt update && apt install -y postgresql-common
RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
RUN apt update && apt install -y postgresql-client-16

RUN gem install bundler --version "2.5.5"

RUN mkdir /veksel
WORKDIR /veksel

COPY veksel.gemspec Gemfile Gemfile.lock /veksel/
COPY lib/veksel/version.rb /veksel/lib/veksel/
COPY bin/veksel /veksel/bin/
ENV BUNDLE_JOBS=4
RUN bundle install

COPY . /veksel
