# Base Ruby
FROM ruby:3.0.3

# Diretório de trabalho
WORKDIR /app

# Dependências do sistema
RUN apt-get update && \
    apt-get install -y build-essential nodejs sqlite3 libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Copiar Gemfile e instalar gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 4 --without development test

# Copiar código da aplicação
COPY . .

# Definir argumentos e variáveis de ambiente para build
ARG RAILS_MASTER_KEY
ENV RAILS_ENV=production
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}

# Pré-compilar assets e preparar DB (produção)
RUN rails assets:precompile
RUN rails db:prepare

# Expor porta dinâmica
EXPOSE 3000

# Entrypoint Rails
CMD ["sh", "-c", "rails server -b 0.0.0.0 -p ${PORT:-3000}"]
