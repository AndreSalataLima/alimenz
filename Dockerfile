# syntax=docker/dockerfile:1
# check=error=true

# Dockerfile para produção com Rails 8 e Ruby 3.2.2 (ou o que estiver em .ruby-version)

ARG RUBY_VERSION=3.2.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Instala pacotes básicos
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Etapa intermediária para build
FROM base AS build

# Cria usuário rails antes de instalar gems (IMPORTANTE!)
RUN getent group rails || groupadd --system --gid 1000 rails && \
    id -u rails || useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash rails


# Instala dependências para compilar gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Usa o usuário rails para o restante da build
USER rails

# Instala gems como rails
COPY --chown=rails:rails Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copia o código da aplicação
COPY --chown=rails:rails . .

# Precompila bootsnap e assets
RUN bundle exec bootsnap precompile app/ lib/
RUN DATABASE_URL=postgresql://ignore/ SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Etapa final
FROM base

# Copia resultado da etapa de build
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Cria usuário rails na imagem final também
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp

USER rails

# Entrypoint e comando padrão
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
