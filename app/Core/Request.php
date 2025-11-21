<?php
declare(strict_types=1);

namespace App\Core;

final class Request
{
    public string $method;
    public string $path;
    public array $get;
    public array $post;
    public array $server;
    public array $cookies;
    public array $files;
    public array $headers;

    private function __construct() {}

    public static function fromGlobals(): self
    {
        $req = new self();
        $req->method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
        $req->path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
        $req->get = $_GET ?? [];
        $req->post = $_POST ?? [];
        $req->server = $_SERVER ?? [];
        $req->cookies = $_COOKIE ?? [];
        $req->files = $_FILES ?? [];
        $req->headers = function_exists('getallheaders') ? getallheaders() : [];
        return $req;
    }

    public function input(string $key, $default = null)
    {
        return $this->post[$key] ?? $this->get[$key] ?? $default;
    }
}
