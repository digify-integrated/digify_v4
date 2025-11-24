<?php

namespace App\Core;

/**
 * Class Response
 * --------------------------------------------------------
 * Handles HTTP responses: status codes, headers, and output.
 * --------------------------------------------------------
 */
class Response
{
    /**
     * Set the HTTP status code
     *
     * @param int $code
     */
    public function setStatusCode(int $code): void
    {
        http_response_code($code);
    }

    /**
     * Set a response header
     *
     * @param string $key
     * @param string $value
     */
    public function setHeader(string $key, string $value): void
    {
        header("$key: $value");
    }

    /**
     * Send a JSON response
     *
     * @param array $data
     */
    public function json(array $data): void
    {
        $this->setHeader('Content-Type', 'application/json');
        echo json_encode($data);
    }
}