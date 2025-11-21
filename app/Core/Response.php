<?php
declare(strict_types=1);

namespace App\Core;

final class Response
{
    private int $status = 200;
    private array $headers = [];

    public function setStatus(int $code): self
    {
        $this->status = $code;
        http_response_code($code);
        return $this;
    }

    public function header(string $name, string $value): self
    {
        header("{$name}: {$value}");
        $this->headers[$name] = $value;
        return $this;
    }

    public function redirect(string $url, int $status = 302): void
    {
        $this->setStatus($status);
        header("Location: {$url}");
        exit;
    }

    public function json($data, int $status = 200): void
    {
        $this->setStatus($status);
        $this->header('Content-Type', 'application/json');
        echo json_encode($data);
        exit;
    }
}
