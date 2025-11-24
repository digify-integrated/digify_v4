<?php

namespace App\Core;

/**
 * Class Request
 * --------------------------------------------------------
 * Handles and normalizes incoming HTTP request data.
 * Extracts URL, method, query parameters, and POST data.
 * --------------------------------------------------------
 */
class Request
{
    /**
     * Get the request HTTP method (GET, POST, etc.)
     *
     * @return string
     */
    public function method(): string
    {
        return strtolower($_SERVER['REQUEST_METHOD'] ?? 'get');
    }

    /**
     * Check if request method is GET
     */
    public function isGet(): bool
    {
        return $this->method() === 'get';
    }

    /**
     * Check if request method is POST
     */
    public function isPost(): bool
    {
        return $this->method() === 'post';
    }

    /**
     * Get sanitized URL path (no query string)
     *
     * @return string
     */
    public function path(): string
    {
        $path = $_SERVER['REQUEST_URI'] ?? '/';

        // Remove query string
        $position = strpos($path, '?');
        if ($position !== false) {
            $path = substr($path, 0, $position);
        }

        return rtrim($path, '/') ?: '/';
    }

    /**
     * Get sanitized request data
     *
     * @return array
     */
    public function input(): array
    {
        $data = [];

        if ($this->isGet()) {
            foreach ($_GET as $key => $value) {
                $data[$key] = htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
            }
        }

        if ($this->isPost()) {
            foreach ($_POST as $key => $value) {
                $data[$key] = htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
            }
        }

        return $data;
    }
}
