<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class ErrorHandler
 * --------------------------------------------------------
 * Centralized error and exception handler.
 * - Logs errors to storage/logs/app.log
 * - Shows detailed errors if APP_DEBUG = true
 * - Displays custom error pages for production
 * - Supports JSON response for API requests
 * --------------------------------------------------------
 */
final class ErrorHandler
{
    private const LOG_DIR = __DIR__ . '/../../storage/logs';
    private const LOG_FILE = 'app.log';

    // --------------------------------------------------------
    // Register Handlers
    // --------------------------------------------------------
    public static function register(): void
    {
        set_error_handler([self::class, 'handleError']);
        set_exception_handler([self::class, 'handleException']);
        register_shutdown_function([self::class, 'handleShutdown']);
    }

    // --------------------------------------------------------
    // Error Handler
    // --------------------------------------------------------
    public static function handleError(int $errno, string $errstr, string $errfile, int $errline): void
    {
        $message = sprintf('[Error][%d] %s in %s on line %d', $errno, $errstr, $errfile, $errline);
        self::log($message);
        self::renderError($message, 500);
    }

    // --------------------------------------------------------
    // Exception Handler
    // --------------------------------------------------------
    public static function handleException(\Throwable $exception): void
    {
        $message = sprintf(
            '[Exception][%s] %s in %s on line %d',
            get_class($exception),
            $exception->getMessage(),
            $exception->getFile(),
            $exception->getLine()
        );

        self::log($message);
        self::renderError($message, 500);
    }

    // --------------------------------------------------------
    // Shutdown Handler (fatal errors)
    // --------------------------------------------------------
    public static function handleShutdown(): void
    {
        $error = error_get_last();
        if ($error !== null) {
            $message = sprintf(
                '[Shutdown][%d] %s in %s on line %d',
                $error['type'],
                $error['message'],
                $error['file'],
                $error['line']
            );

            self::log($message);
            self::renderError($message, 500);
        }
    }

    // --------------------------------------------------------
    // Logging
    // --------------------------------------------------------
    private static function log(string $message): void
    {
        if (!is_dir(self::LOG_DIR)) {
            mkdir(self::LOG_DIR, 0755, true);
        }

        $date = date('Y-m-d H:i:s');
        $logFile = self::LOG_DIR . '/' . self::LOG_FILE;

        file_put_contents($logFile, sprintf("[%s] %s%s", $date, $message, PHP_EOL), FILE_APPEND);
    }

    // --------------------------------------------------------
    // Render Error (HTML or JSON)
    // --------------------------------------------------------
    private static function renderError(string $message, int $statusCode = 500): void
    {
        http_response_code($statusCode);

        $debug = filter_var($_ENV['APP_DEBUG'] ?? 'true', FILTER_VALIDATE_BOOLEAN);
        $isJson = (isset($_SERVER['HTTP_ACCEPT']) && str_contains($_SERVER['HTTP_ACCEPT'], 'application/json'));

        if ($debug && $isJson) {
            header('Content-Type: application/json');
            echo json_encode(['error' => $message], JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
        } elseif ($debug) {
            echo nl2br(htmlspecialchars($message, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'));
        } else {
            $errorPage = dirname(__DIR__, 2) . '/resources/views/error/500.php';
            if (file_exists($errorPage)) {
                require $errorPage;
            } else {
                echo "<h1>500 - Internal Server Error</h1>";
                echo "<p>Something went wrong.</p>";
            }
        }

        exit;
    }
}
