ARG RUBY_VERSION=3.4.1
FROM ruby:${RUBY_VERSION}-slim-bullseye

# Install system packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends \
  apt-utils \
  build-essential \
  curl \
  git \
  imagemagick \
  iproute2 \
  libpq-dev \
  openssh-client \
  postgresql-client \
  vim \
  && rm -rf /var/lib/apt/lists/*

# Install bundler and foreman
RUN gem install bundler foreman

# Install Node.js 20 + Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g yarn

WORKDIR /workspace
