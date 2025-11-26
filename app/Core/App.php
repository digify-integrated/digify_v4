<?php

declare(strict_types=1);

namespace App\Core;

use App\Middleware\CsrfMiddleware;

/**
 * Class App
 * --------------------------------------------------------
 * Main application kernel.
 * - Bootstraps Router, Request, Response
 * - Provides route registration shortcuts
 * - Supports global middleware
 * - Automatically applies CSRF middleware to unsafe methods
 * --------------------------------------------------------
 */
final class App
{
    private Router $router;
    private Request $request;
    private Response $response;

    public function __construct(?Router $router = null, ?Request $request = null, ?Response $response = null)
    {
        $this->request  = $request ?? new Request();
        $this->response = $response ?? new Response();
        $this->router   = $router ?? new Router($this->request, $this->response);

        // Automatically attach CSRF middleware to unsafe HTTP methods
        $this->addGlobalMiddleware(CsrfMiddleware::class);
    }

    // --------------------------------------------------------
    // Route Registration Shortcuts
    // --------------------------------------------------------
    public function get(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->router->get($path, $handler);
    }

    public function post(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->router->post($path, $handler);
    }

    public function put(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->router->put($path, $handler);
    }

    public function delete(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->router->delete($path, $handler);
    }

    // --------------------------------------------------------
    // Route Groups
    // --------------------------------------------------------
    public function group(array $config, callable $callback): void
    {
        $this->router->group($config, $callback);
    }

    // --------------------------------------------------------
    // Global Middleware
    // --------------------------------------------------------
    public function addGlobalMiddleware(string $middleware, ?array $methods = null): void
    {
        // For now, methods parameter is ignored unless Router supports it
        $this->router->addGlobalMiddleware($middleware);
    }

    // --------------------------------------------------------
    // Run Application
    // --------------------------------------------------------
    public function run(): void
    {
        $this->router->resolve();
    }

    // --------------------------------------------------------
    // Access Router / Request / Response
    // --------------------------------------------------------
    public function router(): Router
    {
        return $this->router;
    }

    public function request(): Request
    {
        return $this->request;
    }

    public function response(): Response
    {
        return $this->response;
    }
}
