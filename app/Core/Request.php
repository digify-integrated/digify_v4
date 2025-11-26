<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Request
 * --------------------------------------------------------
 * Handles and normalizes incoming HTTP request data.
 * Provides methods for accessing:
 * - HTTP method
 * - URL path
 * - Query parameters
 * - POST/PUT/DELETE data
 * - JSON payloads
 * - HTTP headers
 * --------------------------------------------------------
 */
final class Request
{
    private string $method;
    private string $path;
    private array $headers;
    private ?array $jsonBody = null;
    private ?array $inputData = null;

    public function __construct()
    {
        $this->method  = strtolower($_SERVER['REQUEST_METHOD'] ?? 'get');
        $this->path    = $this->normalizePath($_SERVER['REQUEST_URI'] ?? '/');
        $this->headers = $this->normalizeHeaders();
    }

    // ================================================================
    // HTTP Method
    // ================================================================
    public function method(): string
    {
        return $this->method;
    }

    public function isGet(): bool
    {
        return $this->method === 'get';
    }

    public function isPost(): bool
    {
        return $this->method === 'post';
    }

    public function isPut(): bool
    {
        return $this->method === 'put';
    }

    public function isDelete(): bool
    {
        return $this->method === 'delete';
    }

    public function isPatch(): bool
    {
        return $this->method === 'patch';
    }

    // ================================================================
    // URL Path
    // ================================================================
    public function path(): string
    {
        return $this->path;
    }

    private function normalizePath(string $uri): string
    {
        $path = parse_url($uri, PHP_URL_PATH) ?: '/';
        return rtrim($path, '/') ?: '/';
    }

    // ================================================================
    // Input Data
    // ================================================================
    /**
     * Get all input data (query, form, or JSON payload)
     */
    public function all(): array
    {
        if ($this->inputData !== null) {
            return $this->inputData;
        }

        if ($this->isJson()) {
            $this->inputData = $this->json();
            return $this->inputData;
        }

        $source = match ($this->method) {
            'get'    => $_GET,
            'post'   => $_POST,
            'put', 'patch', 'delete' => $this->parseInputStream(),
            default => [],
        };

        $this->inputData = $this->sanitizeArray($source);
        return $this->inputData;
    }

    /**
     * Get a single input value
     */
    public function input(string $key, mixed $default = null): mixed
    {
        return $this->all()[$key] ?? $default;
    }

    /**
     * Check if content-type is JSON
     */
    public function isJson(): bool
    {
        $contentType = $this->headers['content-type'] ?? '';
        return str_contains(strtolower($contentType), 'application/json');
    }

    /**
     * Get JSON payload as array
     */
    public function json(): array
    {
        if ($this->jsonBody !== null) {
            return $this->jsonBody;
        }

        $raw = file_get_contents('php://input') ?: '{}';
        $decoded = json_decode($raw, true);

        $this->jsonBody = is_array($decoded) ? $decoded : [];
        return $this->jsonBody;
    }

    // ================================================================
    // Headers
    // ================================================================
    public function headers(): array
    {
        return $this->headers;
    }

    private function normalizeHeaders(): array
    {
        if (function_exists('getallheaders')) {
            return array_change_key_case(getallheaders(), CASE_LOWER);
        }

        $headers = [];
        foreach ($_SERVER as $key => $value) {
            if (str_starts_with($key, 'HTTP_')) {
                $name = strtolower(str_replace('_', '-', substr($key, 5)));
                $headers[$name] = $value;
            }
        }

        return $headers;
    }

    // ================================================================
    // Input Sanitization
    // ================================================================
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

    // ================================================================
    // Parse Input Stream for PUT/PATCH/DELETE
    // ================================================================
    private function parseInputStream(): array
    {
        parse_str(file_get_contents('php://input') ?: '', $parsed);
        return $parsed;
    }
}
