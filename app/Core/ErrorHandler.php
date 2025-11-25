<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class ErrorHandler
 * --------------------------------------------------------
 * Centralized error and exception handler.
 * Logs errors to storage/logs/app.log.
 * Displays detailed errors if APP_DEBUG is true.
 * --------------------------------------------------------
 */
final class ErrorHandler
{
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
        self::display($message);
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
        self::display($message);
    }

    // --------------------------------------------------------
    // Shutdown Handler
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
            self::display($message);
        }
    }

    // --------------------------------------------------------
    // Logging
    // --------------------------------------------------------

    private static function log(string $message): void
    {
        $logDir = dirname(__DIR__, 2) . '/storage/logs';
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }

        $logFile = $logDir . '/app.log';
        $date    = date('Y-m-d H:i:s');

        file_put_contents($logFile, sprintf("[%s] %s%s", $date, $message, PHP_EOL), FILE_APPEND);
    }

    // --------------------------------------------------------
    // Display Error (for debugging only)
    // --------------------------------------------------------

    private static function display(string $message): void
    {
        if (filter_var($_ENV['APP_DEBUG'] ?? 'true', FILTER_VALIDATE_BOOLEAN)) {
            echo nl2br(htmlspecialchars($message, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'));
        }
    }
}
