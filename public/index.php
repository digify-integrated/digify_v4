<?php
declare(strict_types=1);

use App\Core\Container;
use App\Core\ErrorHandler;
use App\Core\Logger;
use App\Core\Request;
use App\Core\Response;
use App\Core\Router;
use App\Core\FileSessionManager;
use Dotenv\Dotenv;
use App\Core\Middleware\CsrfMiddleware;

require __DIR__ . '/../vendor/autoload.php';

/**
 * Bootstrap environment
 */
$root = dirname(__DIR__);
$dotenv = Dotenv::createImmutable($root);
$dotenv->safeLoad(); // safeLoad won't crash if .env is missing

// Basic config values
$appEnv = $_ENV['APP_ENV'] ?? 'production';
$appDebug = filter_var($_ENV['APP_DEBUG'] ?? 'false', FILTER_VALIDATE_BOOLEAN);
$logPath = $_ENV['LOG_PATH'] ?? $root . '/storage/logs/app.log';

/**
 * Create container and register core services
 */
$container = new Container();

// Logger
$container->bind('logger', function() use ($logPath) {
    return new Logger($logPath);
});

// Error handler (register early)
$errorHandler = new ErrorHandler($container->get('logger'), $appEnv, $appDebug);
set_exception_handler([$errorHandler, 'handleException']);
set_error_handler([$errorHandler, 'handleError']);
register_shutdown_function([$errorHandler, 'handleShutdown']);

// Session manager
$container->bind('session', function() {
    // FileSessionManager implements App\Core\SessionManagerInterface
    return new FileSessionManager();
});

// CSRF
$container->bind('csrf', function() {
    return new \App\Core\Csrf(app('session'));
});

// Request & Response
$container->bind('request', function() {
    return App\Core\Request::fromGlobals();
});
$container->bind('response', function() {
    return new App\Core\Response();
});

// Router
$container->bind('router', function() {
    return new App\Core\Router();
});

// Make container available to helpers
App\Core\Container::setInstance($container);

// Load helpers
require_once __DIR__ . '/../app/helpers.php';

// Load routes
$routesPath = __DIR__ . '/../routes/web.php';
if (file_exists($routesPath)) {
    require $routesPath;
}

// Dispatch
/** @var Router $router */
$router = $container->get('router');

$router->middleware([
    CsrfMiddleware::class
]);

$request = $container->get('request');
$response = $container->get('response');

try {
    $router->dispatch($request, $response);
} catch (Throwable $e) {
    // Debug
    echo '<pre>';
    echo 'Exception: ' . get_class($e) . PHP_EOL;
    echo 'Message: ' . $e->getMessage() . PHP_EOL;
    echo 'File: ' . $e->getFile() . ' Line: ' . $e->getLine() . PHP_EOL;
    echo 'Trace:' . PHP_EOL . $e->getTraceAsString();
    echo '</pre>';
    exit;
}
