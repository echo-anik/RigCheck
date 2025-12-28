FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libzip-dev \
    libxml2-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u 1000 -d /home/khand khand
RUN mkdir -p /home/khand/.composer && \
    chown -R khand:khand /home/khand

# Copy custom php.ini
COPY docker/php/local.ini /usr/local/etc/php/conf.d/local.ini

# Set working directory ownership
RUN chown -R khand:www-data /var/www

# Switch to user
USER khand

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
