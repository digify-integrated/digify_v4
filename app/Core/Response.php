<?php

declare(strict_types=1);

namespace App\Core;

use JsonException;

/**
 * Class Response
 * --------------------------------------------------------
 * Handles HTTP responses: status codes, headers, redirects,
 * JSON output, and simple view rendering.
 * --------------------------------------------------------
 */
final class Response
{
    private int $statusCode = 200;

    /** @var array<string, string> */
    private array $headers = [];

    // ================================================================
    // Status Code
    // ================================================================
    public function setStatusCode(int $code): self
    {
        if ($code < 100 || $code > 599) {
            throw new \InvalidArgumentException("Invalid HTTP status code: {$code}");
        }

        $this->statusCode = $code;
        http_response_code($code);

        return $this;
    }

    public function getStatusCode(): int
    {
        return $this->statusCode;
    }

    // ================================================================
    // Headers
    // ================================================================
    public function setHeader(string $key, string $value): self
    {
        $this->headers[$key] = $value;
        header("{$key}: {$value}", true);

        return $this;
    }

    public function getHeaders(): array
    {
        return $this->headers;
    }

    // ================================================================
    // JSON Response
    // ================================================================
    public function json(array $data, int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode)
             ->setHeader('Content-Type', 'application/json; charset=utf-8');

        try {
            echo json_encode(
                $data,
                JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR
            );
        } catch (JsonException $e) {
            $this->setStatusCode(500)
                 ->text('Failed to encode JSON response: ' . $e->getMessage(), 500);
        }
    }

    // ================================================================
    // Plain Text Response
    // ================================================================
    public function text(string $text, int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode)
             ->setHeader('Content-Type', 'text/plain; charset=utf-8');

        echo $text;
    }

    // ================================================================
    // HTML / View Rendering
    // ================================================================
    public function render(string $viewPath, array $data = [], int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode);

        $file = __DIR__ . '/../Views/' . ltrim($viewPath, '/') . '.php';

        if (!file_exists($file)) {
            $this->setStatusCode(500)
                 ->text("View file '{$viewPath}' not found.", 500);
            return;
        }

        extract($data, EXTR_SKIP);
        include $file;
    }

    // ================================================================
    // Redirect
    // ================================================================
    public function redirect(string $url, int $statusCode = 302): void
    {
        if (!filter_var($url, FILTER_VALIDATE_URL)) {
            throw new \InvalidArgumentException("Invalid redirect URL: {$url}");
        }

        $this->setStatusCode($statusCode)
             ->setHeader('Location', $url);

        exit;
    }

    // ================================================================
    // Generic Raw Response
    // ================================================================
    public function send(string $content, string $contentType = 'text/html', int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode)
             ->setHeader('Content-Type', $contentType . '; charset=utf-8');

        echo $content;
    }
}
