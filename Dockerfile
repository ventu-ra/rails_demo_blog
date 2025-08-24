# =========================
# Stage 1: Build
# =========================
FROM ruby:3.0.3-slim AS build

WORKDIR /app

RUN apt-get update && \
    apt-get install -y build-essential nodejs sqlite3 libsqlite3-dev imagemagick && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 4 --without development test && \
    rm -rf /usr/local/bundle/cache

COPY . .

ARG RAILS_MASTER_KEY
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

RUN bundle exec rails assets:precompile

# =========================
# Stage 2: Runtime
# =========================
FROM ruby:3.0.3-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y nodejs sqlite3 imagemagick && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Porta Render
EXPOSE 3000

# Inicialização: criar storage, preparar banco e iniciar Rails
CMD ["sh", "-c", "mkdir -p db storage tmp && chmod -R 777 storage tmp db && bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
