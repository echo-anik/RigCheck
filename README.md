# RigCheck API

RESTful API service for PC component data, build management, and compatibility checking.

## Overview

RigCheck API provides backend services for the RigCheck platform, handling component data management, build operations, user authentication, and compatibility validation for custom PC builds.

## Features

- Component catalog with detailed specifications
- Build creation and management
- Compatibility checking engine
- User authentication and authorization
- Build sharing and social features
- Price tracking and updates
- Admin tools for data management

## Technology Stack

- Laravel 10
- PHP 8.2+
- MySQL 8.0
- JWT Authentication
- RESTful API architecture

## Getting Started

### Prerequisites

- PHP 8.2 or higher
- Composer
- MySQL 8.0 or higher
- Web server (Apache/Nginx)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   composer install
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   ```

4. Update database credentials in `.env`

5. Generate application key:
   ```bash
   php artisan key:generate
   ```

6. Run migrations:
   ```bash
   php artisan migrate
   ```

7. Seed initial data (optional):
   ```bash
   php artisan db:seed
   ```

### Development

Start the development server:

```bash
php artisan serve
```

The API will be available at `http://localhost:8000`

## API Endpoints

### Authentication
- POST `/api/v1/register` - User registration
- POST `/api/v1/login` - User login
- POST `/api/v1/logout` - User logout

### Components
- GET `/api/v1/components` - List components
- GET `/api/v1/components/{id}` - Get component details
- GET `/api/v1/components/search` - Search components

### Builds
- GET `/api/v1/builds/public` - List public builds
- GET `/api/v1/builds/my` - List user builds
- POST `/api/v1/builds` - Create build
- GET `/api/v1/builds/{id}` - Get build details
- PUT `/api/v1/builds/{id}` - Update build
- DELETE `/api/v1/builds/{id}` - Delete build

### Compatibility
- POST `/api/v1/builds/validate` - Validate component compatibility

## Database Structure

Key tables:
- `components` - PC components catalog
- `builds` - User PC builds
- `build_components` - Build-component relationships
- `users` - User accounts
- `component_specs` - Component specifications
- `component_prices` - Price tracking data

## License

All rights reserved.
