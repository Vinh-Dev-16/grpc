FROM php:8.2-cli-alpine

# -----------------------------
# 1️⃣ Install system dependencies
# -----------------------------
RUN set -eux; \
    apk add --no-cache \
        git \
        unzip \
        libzip-dev \
        protobuf-dev \
        protobuf \
        wget \
        curl \
        autoconf \
        g++ \
        make \
        openssl-dev \
        zlib-dev; \
    docker-php-ext-install zip pcntl sockets

# -----------------------------
# 2️⃣ Install gRPC + Protobuf (optimized)
# -----------------------------
RUN set -eux; \
    curl -L -o /tmp/grpc.tgz https://pecl.php.net/get/grpc-1.62.0.tgz; \
    curl -L -o /tmp/protobuf.tgz https://pecl.php.net/get/protobuf-3.25.5.tgz; \
    pecl install /tmp/grpc.tgz /tmp/protobuf.tgz; \
    docker-php-ext-enable grpc protobuf; \
    rm -rf /tmp/*.tgz /tmp/pear ~/.pearrc

# -----------------------------
# 3️⃣ Install Composer
# -----------------------------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# -----------------------------
# 4️⃣ Install RoadRunner
# -----------------------------
RUN wget -q https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/roadrunner-2023.3.8-linux-amd64.tar.gz \
 && tar -xzf roadrunner-2023.3.8-linux-amd64.tar.gz \
 && mv roadrunner-2023.3.8-linux-amd64/rr /usr/local/bin/rr \
 && chmod +x /usr/local/bin/rr \
 && rm -rf roadrunner-2023.3.8-linux-amd64*

# -----------------------------
# 5️⃣ Install protoc-gen-php-grpc
# -----------------------------
RUN wget -q https://github.com/roadrunner-server/roadrunner/releases/download/v2023.3.8/protoc-gen-php-grpc-2023.3.8-linux-amd64.tar.gz \
 && tar -xzf protoc-gen-php-grpc-2023.3.8-linux-amd64.tar.gz \
 && mv protoc-gen-php-grpc /usr/local/bin/ \
 && chmod +x /usr/local/bin/protoc-gen-php-grpc \
 && rm -rf protoc-gen-php-grpc* *.tar.gz

# -----------------------------
# 6️⃣ Setup application
# -----------------------------
WORKDIR /app

# Copy composer files first (for caching)
COPY composer.json composer.lock* ./
RUN composer install --no-scripts --no-autoloader --prefer-dist --no-interaction

# Copy source code
COPY . .

# Ensure proto directory exists
RUN mkdir -p proto/tour && chmod -R 755 proto

# Optimize autoloader
RUN composer dump-autoload --optimize --no-scripts

# -----------------------------
# 7️⃣ Final setup
# -----------------------------
EXPOSE 6000
CMD ["rr", "serve"]
