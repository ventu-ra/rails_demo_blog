# =========================
# Stage 1: Build
# =========================
FROM ruby:3.0.3-slim AS build

WORKDIR /app

# Dependências de sistema para build
RUN apt-get update && \
    apt-get install -y build-essential nodejs sqlite3 libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Copiar Gemfile e instalar gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install --jobs 4 --without development test && \
    rm -rf /usr/local/bundle/cache

# Copiar aplicação
COPY . .

# Variáveis de ambiente
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Pré-compilar assets
RUN bundle exec rails assets:precompile

# =========================
# Stage 2: Runtime
# =========================
FROM ruby:3.0.3-slim

WORKDIR /app

# Essentials runtime
RUN apt-get update && \
    apt-get install -y nodejs sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# Copiar gems do build
COPY --from=build /usr/local/bundle /usr/local/bundle

# Copiar aplicação do build
COPY --from=build /app /app

# Variáveis de ambiente
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Porta dinâmica Render
EXPOSE 3000

# Preparar banco SQLite e storage Action Text antes de iniciar
CMD ["sh", "-c", "mkdir -p db storage && bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
