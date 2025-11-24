<?php

namespace App\Core;

/**
 * Class ErrorHandler
 * --------------------------------------------------------
 * Custom error and exception handler.
 * Logs all errors to storage/logs/app.log
 * Displays detailed errors in development mode.
 * --------------------------------------------------------
 */
class ErrorHandler
{
    /**
     * Register custom error and exception handlers
     */
    public function register(): void
    {
        set_error_handler([$this, 'handleError']);
        set_exception_handler([$this, 'handleException']);
        register_shutdown_function([$this, 'handleShutdown']);
    }

    /**
     * Handle PHP errors
     */
    public function handleError(int $errno, string $errstr, string $errfile, int $errline): void
    {
        $message = "[Error][$errno] $errstr in $errfile on line $errline";
        $this->log($message);

        if ($_ENV['APP_DEBUG'] ?? false) {
            echo nl2br($message);
        }
    }

    /**
     * Handle uncaught exceptions
     */
    public function handleException(\Throwable $exception): void
    {
        $message = "[Exception][" . get_class($exception) . "] "
            . $exception->getMessage()
            . " in " . $exception->getFile()
            . " on line " . $exception->getLine();

        $this->log($message);

        if ($_ENV['APP_DEBUG'] ?? false) {
            echo nl2br($message);
        }
    }

    /**
     * Handle fatal errors on shutdown
     */
    public function handleShutdown(): void
    {
        $error = error_get_last();
        if ($error) {
            $message = "[Shutdown][{$error['type']}] {$error['message']} in {$error['file']} on line {$error['line']}";
            $this->log($message);

            if ($_ENV['APP_DEBUG'] ?? false) {
                echo nl2br($message);
            }
        }
    }

    /**
     * Log message to storage/logs/app.log
     */
    protected function log(string $message): void
    {
        $logDir = dirname(__DIR__, 2) . '/storage/logs';
        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }

        $logFile = $logDir . '/app.log';
        $date = date('Y-m-d H:i:s');
        file_put_contents($logFile, "[$date] $message" . PHP_EOL, FILE_APPEND);
    }
}
