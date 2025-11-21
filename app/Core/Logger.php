<?php
declare(strict_types=1);

namespace App\Core;

class Logger
{
    private string $path;

    public function __construct(string $path)
    {
        $this->path = $path;
        // ensure directory exists
        $dir = dirname($path);
        if (!is_dir($dir)) {
            @mkdir($dir, 0755, true);
        }
    }

    public function log(string $level, string $message, array $context = []): void
    {
        $time = (new \DateTime())->format('Y-m-d H:i:s');
        $ctx = $context ? ' | ' . json_encode($context, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) : '';
        $line = "[{$time}] {$level}: {$message}{$ctx}\n";
        @file_put_contents($this->path, $line, FILE_APPEND | LOCK_EX);
    }

    public function info(string $message, array $context = []): void
    {
        $this->log('INFO', $message, $context);
    }

    public function error(string $message, array $context = []): void
    {
        $this->log('ERROR', $message, $context);
    }

    public function debug(string $message, array $context = []): void
    {
        $this->log('DEBUG', $message, $context);
    }
}
