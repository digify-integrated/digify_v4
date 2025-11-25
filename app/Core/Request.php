<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Request
 * --------------------------------------------------------
 * Handles and normalizes incoming HTTP request data.
 * Provides methods for accessing URL, HTTP method,
 * query parameters, POST data, headers, and JSON payloads.
 * --------------------------------------------------------
 */
final class Request
{
    /**
     * Get the HTTP method (lowercased)
     */
    public function method(): string
    {
        return strtolower($_SERVER['REQUEST_METHOD'] ?? 'get');
    }

    /**
     * Shortcut: is GET request
     */
    public function isGet(): bool
    {
        return $this->method() === 'get';
    }

    /**
     * Shortcut: is POST request
     */
    public function isPost(): bool
    {
        return $this->method() === 'post';
    }

    /**
     * Shortcut: is PUT request
     */
    public function isPut(): bool
    {
        return $this->method() === 'put';
    }

    /**
     * Shortcut: is DELETE request
     */
    public function isDelete(): bool
    {
        return $this->method() === 'delete';
    }

    /**
     * Get sanitized URL path (without query string)
     */
    public function path(): string
    {
        $uri = $_SERVER['REQUEST_URI'] ?? '/';
        $uri = parse_url($uri, PHP_URL_PATH) ?: '/';
        return rtrim($uri, '/') ?: '/';
    }

    /**
     * Get all input data (GET, POST, or JSON body)
     */
    public function all(): array
    {
        if ($this->isJson()) {
            return $this->json();
        }

        $source = match ($this->method()) {
            'get'    => $_GET,
            'post'   => $_POST,
            'put', 'patch', 'delete' => $this->parseInputStream(),
            default => [],
        };

        return $this->sanitizeArray($source);
    }

    /**
     * Get a single input field with default
     */
    public function input(string $key, mixed $default = null): mixed
    {
        $data = $this->all();
        return $data[$key] ?? $default;
    }

    /**
     * Check if request content type is JSON
     */
    public function isJson(): bool
    {
        $contentType = $this->headers()['Content-Type'] ?? '';
        return str_contains($contentType, 'application/json');
    }

    /**
     * Get JSON payload as array
     */
    public function json(): array
    {
        $input = file_get_contents('php://input');
        $data = json_decode($input ?: '{}', true);
        return is_array($data) ? $data : [];
    }

    /**
     * Get all HTTP headers (normalized)
     */
    public function headers(): array
    {
        if (function_exists('getallheaders')) {
            return array_change_key_case(getallheaders(), CASE_LOWER);
        }

        $headers = [];
        foreach ($_SERVER as $key => $value) {
            if (str_starts_with($key, 'HTTP_')) {
                $name = str_replace('_', '-', substr($key, 5));
                $headers[strtolower($name)] = $value;
            }
        }

        return $headers;
    }

    /**
     * Sanitize an array recursively
     */
    private function sanitizeArray(array $data): array
    {
        foreach ($data as $key => $value) {
            if (is_array($value)) {
                $data[$key] = $this->sanitizeArray($value);
            } else {
                $data[$key] = htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
            }
        }
        return $data;
    }

    /**
     * Parse input stream for PUT/PATCH/DELETE requests
     */
    private function parseInputStream(): array
    {
        parse_str(file_get_contents('php://input') ?: '', $parsed);
        return $parsed;
    }
}
