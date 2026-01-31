#!/bin/bash
set -e

echo "🚀 Starting Laravel container setup..."

# ===============================
# STEP 1: Create Laravel Project
# ===============================
if [ -z "$(find /var/www/html -mindepth 1 -not -path '/var/www/html/.gitkeep' -print -quit)" ]; then
  echo "📦 Creating Laravel project (fila-starter)..."
  composer create-project --prefer-dist raugadh/fila-starter . --no-interaction
else
  echo "✅ Laravel project already exists."
fi

# ===============================
# STEP 2: Environment (.env)
# ===============================
echo "📄 Writing .env file..."
cat <<EOF > /var/www/html/.env
APP_NAME="${PROJECT_NAME}"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_TIMEZONE=Asia/Jakarta
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mariadb
DB_HOST=db
DB_PORT=3306
DB_DATABASE="${PROJECT_NAME}"
DB_USERNAME=root
DB_PASSWORD=p455w0rd

SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=database

REDIS_CLIENT=phpredis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
EOF

# ===============================
# STEP 3: Wait Database
# ===============================
echo "⏳ Waiting for database..."
until nc -z db 3306; do sleep 2; done
echo "✅ Database ready!"

# ===============================
# STEP 4: Composer Install
# ===============================
if [ ! -d vendor ]; then
  echo "📦 Installing dependencies..."
  composer install --no-interaction
fi

# ===============================
# STEP 5: App Key
# ===============================
php artisan key:generate --force

# ===============================
# STEP 6: Permission
# ===============================
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

# ===============================
# STEP 7: Migration
# ===============================
php artisan migrate --force

# ===============================
# 🔥 STEP 8: API SETUP (NEW)
# ===============================

echo "🔌 Installing Laravel Sanctum (API)..."
composer require laravel/sanctum --no-interaction || true

php artisan vendor:publish --provider="Laravel\\Sanctum\\SanctumServiceProvider" --force
php artisan migrate --force

echo "🛣️ Creating API base route..."
if ! grep -q "api/health" routes/api.php; then
cat <<EOF >> routes/api.php

use Illuminate\\Http\\Request;

Route::get('/health', function () {
    return response()->json([
        'status' => 'OK',
        'service' => 'API is running'
    ]);
});

Route::middleware('auth:sanctum')->get('/user', function (Request \$request) {
    return \$request->user();
});
EOF
fi

# ===============================
# STEP 9: Storage Link
# ===============================
php artisan storage:link || true

# ===============================
# STEP 10: Optimize
# ===============================
php artisan optimize:clear
php artisan optimize

# ===============================
# STEP 11: Cron
# ===============================
service cron start

echo "✅ Laravel + API setup complete!"

exec "$@"
