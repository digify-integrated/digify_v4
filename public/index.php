<?php

declare(strict_types=1);

// ================================================================
// Composer Autoload
// ================================================================
require_once __DIR__ . '/../vendor/autoload.php';

use App\Core\App;
use App\Core\Config;
use App\Core\ErrorHandler;
use Dotenv\Dotenv;

// ================================================================
// Load Environment Variables (.env)
// ================================================================
$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->safeLoad(); // Do not throw if .env is missing

// ================================================================
// Mandatory Environment Variable Validation
// ================================================================
$requiredEnv = [
    'APP_ENV',
    'APP_DEBUG',
    'APP_TIMEZONE',
    'APP_KEY',
    'DB_CONNECTION',
    'DB_HOST',
    'DB_DATABASE',
    'DB_USERNAME',
];

foreach ($requiredEnv as $key) {
    if (!isset($_ENV[$key]) || $_ENV[$key] === '') {
        throw new RuntimeException("Missing required environment variable: {$key}");
    }
}

// ================================================================
// Start Secure Session
// ================================================================
if (session_status() !== PHP_SESSION_ACTIVE) {
    session_set_cookie_params([
        'lifetime' => 0,                       // Session lasts until browser closes
        'path'     => '/',
        'domain'   => $_SERVER['HTTP_HOST'] ?? '', 
        'secure'   => (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off'),
        'httponly' => true,
        'samesite' => 'Lax',                   // Could be 'Strict' if needed
    ]);

    session_start();
}

// ================================================================
// Set Default Timezone
// ================================================================
date_default_timezone_set(Config::string('APP_TIMEZONE', 'Asia/Manila'));

// ================================================================
// Register Global Error & Exception Handler
// ================================================================
ErrorHandler::register();

// ================================================================
// Set Security HTTP Headers
// ================================================================
header("X-Frame-Options: SAMEORIGIN");
header("X-Content-Type-Options: nosniff");
header("Referrer-Policy: strict-origin-when-cross-origin");
header("X-XSS-Protection: 1; mode=block");

// Optional CSP (adjust for your frontend)
// header("Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self';");

// ================================================================
// Initialize Application Kernel
// ================================================================
$app = new App();

// ================================================================
// Register Global Middleware (Optional)
// ================================================================
// $app->addGlobalMiddleware(\App\Middleware\CsrfMiddleware::class);
// $app->addGlobalMiddleware(\App\Middleware\AuthMiddleware::class);

// ================================================================
// Load Routes
// ================================================================
require_once dirname(__DIR__) . '/routes/web.php';

// ================================================================
// Dispatch Incoming Request
// ================================================================
$app->run();
