# Build stage
FROM ruby:3.0.3-slim AS build

WORKDIR /app

# Dependências do sistema necessárias para build
RUN apt-get update && \
    apt-get install -y build-essential nodejs sqlite3 libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Copiar Gemfile e instalar gems (sem desenvolvimento/teste)
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && \
    bundle install --jobs 4 --without development test && \
    rm -rf /usr/local/bundle/cache

# Copiar código da aplicação
COPY . .

# Pré-compilar assets
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
RUN rails assets:precompile

# Stage final (runtime)
FROM ruby:3.0.3-slim

WORKDIR /app

# Apenas runtime essentials
RUN apt-get update && apt-get install -y nodejs sqlite3 && \
    rm -rf /var/lib/apt/lists/*

# Copiar aplicação e gems do build
COPY --from=build /app /app

EXPOSE 3000

# Entrypoint Rails
CMD ["sh", "-c", "rails server -b 0.0.0.0 -p ${PORT:-3000}"]
