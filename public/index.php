<?php

declare(strict_types=1);

// --------------------------------------------------------
// Composer Autoload
// --------------------------------------------------------
require_once __DIR__ . '/../vendor/autoload.php';

use App\Core\App;
use App\Core\Config;
use App\Core\ErrorHandler;
use Dotenv\Dotenv;

// --------------------------------------------------------
// Load Environment Variables (.env)
// --------------------------------------------------------
$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->safeLoad();   // safeLoad() will not throw an exception if .env is missing

// --------------------------------------------------------
// Mandatory Environment Variable Validation
// --------------------------------------------------------
$requiredEnv = [
    'APP_ENV',
    'APP_DEBUG',
    'APP_TIMEZONE',
    'DB_CONNECTION',
    'DB_HOST',
    'DB_NAME',
    'DB_USER',
];

foreach ($requiredEnv as $key) {
    if (!isset($_ENV[$key]) || $_ENV[$key] === '') {
        throw new RuntimeException("Missing required environment variable: {$key}");
    }
}

// --------------------------------------------------------
// Start Secure Session
// --------------------------------------------------------
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_set_cookie_params([
        'lifetime' => 0,
        'path'     => '/',
        'domain'   => '',
        'secure'   => isset($_SERVER['HTTPS']),
        'httponly' => true,
        'samesite' => 'Lax',
    ]);

    session_start();
}

// --------------------------------------------------------
// Set Default Timezone
// --------------------------------------------------------
date_default_timezone_set(Config::env('APP_TIMEZONE', 'Asia/Manila'));

// --------------------------------------------------------
// Register Error Handler
// --------------------------------------------------------

ErrorHandler::register();

// --------------------------------------------------------
// Set Security Headers
// --------------------------------------------------------
header("X-Frame-Options: SAMEORIGIN");
header("X-Content-Type-Options: nosniff");
header("Referrer-Policy: strict-origin-when-cross-origin");
header("X-XSS-Protection: 1; mode=block");

// Optional CSP (Developer should adjust based on frontend)
// header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self';");

// --------------------------------------------------------
// Initialize Application Kernel
// --------------------------------------------------------
$app = new App();

// --------------------------------------------------------
// Register Global Middleware (Optional)
// --------------------------------------------------------
// $app->addGlobalMiddleware(\App\Middleware\CsrfMiddleware::class);
// $app->addGlobalMiddleware(\App\Middleware\AuthMiddleware::class);

// --------------------------------------------------------
// Load Routes
// --------------------------------------------------------
require_once dirname(__DIR__) . '/routes/web.php';

// --------------------------------------------------------
// Dispatch Incoming Request
// --------------------------------------------------------
$app->run();
