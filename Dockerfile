FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    protobuf-compiler \
    wget \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    autoconf \
    && docker-php-ext-install zip pcntl sockets \
    && rm -rf /var/lib/apt/lists/*

# Install PHP gRPC extension - FAST METHOD
# Sử dụng pecl nhưng với optimization
RUN pecl channel-update pecl.php.net \
    && MAKEFLAGS="-j$(nproc)" pecl install grpc \
    && docker-php-ext-enable grpc \
    && pecl clear-cache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install RoadRunner
RUN wget https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64.tar.gz \
    && tar -xzf roadrunner-2023.3.8-linux-amd64.tar.gz \
    && mv roadrunner-2023.3.8-linux-amd64/rr /usr/local/bin/rr \
    && chmod +x /usr/local/bin/rr \
    && rm -rf roadrunner-*

# Install protoc-gen-php-grpc
RUN wget https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/protoc-gen-php-grpc-2023.3.8-linux-amd64.tar.gz \
    && tar -xzf protoc-gen-php-grpc-2023.3.8-linux-amd64.tar.gz \
    && find . -name "protoc-gen-php-grpc" -type f -exec mv {} /usr/local/bin/ \; \
    && chmod +x /usr/local/bin/protoc-gen-php-grpc \
    && rm -rf protoc-gen-php-grpc* *.tar.gz

# Set working directory
WORKDIR /app

# Avoid git "dubious ownership" when running as root in container
RUN git config --global --add safe.directory /app

# Copy composer files
COPY composer.json composer.lock* ./

# Install PHP dependencies (sync lock if out-of-date)
RUN composer update --no-scripts --no-autoloader --no-interaction

# Copy application code
COPY . .

# Create proto directory structure if not exists
RUN mkdir -p proto/tour && chmod -R 755 proto

# Generate autoload files (skip scripts - will run later)
RUN composer dump-autoload --optimize --no-scripts

# Expose gRPC port
EXPOSE 6000

CMD ["rr", "serve"]