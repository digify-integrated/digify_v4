<?php
declare(strict_types=1);

namespace App\Core;

class ErrorHandler
{
    private Logger $logger;
    private string $env;
    private bool $debug;

    public function __construct(Logger $logger, string $env = 'production', bool $debug = false)
    {
        $this->logger = $logger;
        $this->env = $env;
        $this->debug = $debug;
    }

    public function handleException(\Throwable $e): void
    {
        $this->logger->error($e->getMessage(), [
            'file' => $e->getFile(),
            'line' => $e->getLine(),
            'trace' => $e->getTraceAsString(),
            'class' => get_class($e)
        ]);

        if ($this->debug) {
            // Detailed HTML output for development
            http_response_code(500);
            echo "<h1>Uncaught Exception</h1>";
            echo "<p><strong>Message:</strong> " . e($e->getMessage()) . "</p>";
            echo "<p><strong>File:</strong> " . e($e->getFile()) . " on line " . e((string)$e->getLine()) . "</p>";
            echo "<pre>" . e($e->getTraceAsString()) . "</pre>";
        } else {
            http_response_code(500);
            echo "An error occurred. Please contact the system administrator.";
        }
    }

    public function handleError(int $severity, string $message, string $file, int $line): void
    {
        $this->logger->error($message, ['file' => $file, 'line' => $line, 'severity' => $severity]);
        if ($this->debug) {
            throw new \ErrorException($message, 0, $severity, $file, $line);
        }
    }

    public function handleShutdown(): void
    {
        $error = error_get_last();
        if ($error !== null) {
            $this->logger->error('Shutdown error', $error);
            if ($this->debug) {
                echo '<pre>';
                print_r($error);
                echo '</pre>';
            }
        }
    }
}
