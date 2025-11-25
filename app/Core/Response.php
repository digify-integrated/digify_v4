<?php

declare(strict_types=1);

namespace App\Core;

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

    // --------------------------------------------------------
    // Status Code
    // --------------------------------------------------------

    public function setStatusCode(int $code): self
    {
        $this->statusCode = $code;
        http_response_code($code);

        return $this;
    }

    public function getStatusCode(): int
    {
        return $this->statusCode;
    }

    // --------------------------------------------------------
    // Headers
    // --------------------------------------------------------

    public function setHeader(string $key, string $value): self
    {
        $this->headers[$key] = $value;
        header("$key: $value");

        return $this;
    }

    // --------------------------------------------------------
    // Responses
    // --------------------------------------------------------

    public function json(array $data, int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode)
             ->setHeader('Content-Type', 'application/json');

        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR);
    }

    public function text(string $text, int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode)
             ->setHeader('Content-Type', 'text/plain');

        echo $text;
    }

    public function render(string $viewPath, array $data = [], int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode);

        $file = __DIR__ . '/../Views/' . $viewPath . '.php';

        if (!file_exists($file)) {
            $this->setStatusCode(500)
                 ->text("View file '{$viewPath}' not found.", 500);
            return;
        }

        extract($data, EXTR_SKIP);
        include $file;
    }

    public function redirect(string $url, int $statusCode = 302): void
    {
        $this->setStatusCode($statusCode)
             ->setHeader('Location', $url);

        exit;
    }

    // --------------------------------------------------------
    // Convenience: send raw response
    // --------------------------------------------------------

    public function send(string $content, string $contentType = 'text/html', int $statusCode = 200): void
    {
        $this->setStatusCode($statusCode)
             ->setHeader('Content-Type', $contentType);

        echo $content;
    }
}
