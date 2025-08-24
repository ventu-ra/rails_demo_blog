# Base Ruby
FROM ruby:3.0.3

# Diretório de trabalho
WORKDIR /app

# Instalar dependências do sistema
RUN apt-get update && \
    apt-get install -y build-essential nodejs sqlite3 libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Copiar Gemfile e instalar gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 4 --without development test

# Copiar todo o código
COPY . .

# Pré-compilar assets para produção
RUN RAILS_ENV=production rails assets:precompile

# Banco de dados para produção (SQLite)
RUN RAILS_ENV=production rails db:prepare

# Expor porta (usada pelo Railway/Render)
EXPOSE 3000

# Comando para iniciar o Rails em produção
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
