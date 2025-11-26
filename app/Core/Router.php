<?php

declare(strict_types=1);

namespace App\Core;

use App\Core\Request;
use App\Core\Response;
use Exception;

/**
 * Class Router
 * --------------------------------------------------------
 * Handles HTTP routing:
 * - Static & dynamic routes
 * - Route groups with prefixes and middleware
 * - Global middleware
 * - Custom 404 page
 * --------------------------------------------------------
 */
final class Router
{
    private Request $request;
    private Response $response;

    /** @var array<string, array<string, RouteConfig>> */
    private array $routes = [
        'get'    => [],
        'post'   => [],
        'put'    => [],
        'patch'  => [],
        'delete' => [],
    ];

    /** @var array<class-string> */
    private array $globalMiddleware = [];

    private array $currentGroup = [];

    public function __construct(Request $request, Response $response)
    {
        $this->request  = $request;
        $this->response = $response;
    }

    // ================================================================
    // Route Registration
    // ================================================================
    public function get(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->addRoute('get', $path, $handler);
    }

    public function post(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->addRoute('post', $path, $handler);
    }

    public function put(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->addRoute('put', $path, $handler);
    }

    public function patch(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->addRoute('patch', $path, $handler);
    }

    public function delete(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->addRoute('delete', $path, $handler);
    }

    private function addRoute(string $method, string $path, callable|string|array $handler): RouteConfig
    {
        // Apply group prefix
        if (!empty($this->currentGroup['prefix'])) {
            $path = rtrim($this->currentGroup['prefix'], '/') . '/' . ltrim($path, '/');
        }

        $config = new RouteConfig([
            'handler'    => $handler,
            'middleware' => $this->currentGroup['middleware'] ?? [],
        ]);

        $this->routes[$method][$path] = $config;

        return $config;
    }

    // ================================================================
    // Route Groups
    // ================================================================
    public function group(array $config, callable $callback): void
    {
        $previousGroup = $this->currentGroup;

        $this->currentGroup = [
            'prefix'     => $config['prefix'] ?? ($previousGroup['prefix'] ?? ''),
            'middleware' => $config['middleware'] ?? ($previousGroup['middleware'] ?? []),
        ];

        $callback($this);

        $this->currentGroup = $previousGroup;
    }

    // ================================================================
    // Global Middleware
    // ================================================================
    public function addGlobalMiddleware(string $middlewareClass): void
    {
        if (!class_exists($middlewareClass)) {
            throw new Exception("Middleware class {$middlewareClass} does not exist.");
        }

        $this->globalMiddleware[] = $middlewareClass;
    }

    // ================================================================
    // Route Resolution
    // ================================================================
    public function resolve(): void
    {
        $method      = $this->request->method();
        $currentPath = $this->request->path();

        foreach ($this->routes[$method] ?? [] as $routePattern => $config) {
            if (preg_match($this->convertToRegex($routePattern), $currentPath, $matches)) {
                array_shift($matches); // Remove full match
                $this->dispatch($config, $matches);
                return;
            }
        }

        $this->render404();
    }

    // ================================================================
    // Dispatch Route with Middleware
    // ================================================================
    private function dispatch(RouteConfig $routeConfig, array $params): void
    {
        $handler = $routeConfig->getHandler();
        $middlewareStack = array_merge($this->globalMiddleware, $routeConfig->getMiddleware());

        $next = function () use ($handler, $params) {
            if (is_callable($handler)) {
                echo call_user_func_array($handler, $params);
                return;
            }

            if (is_string($handler)) {
                [$controllerName, $method] = explode('@', $handler);
                $controllerClass = "App\\Controllers\\$controllerName";

                if (!class_exists($controllerClass)) {
                    throw new Exception("Controller {$controllerClass} not found.");
                }

                $controller = new $controllerClass();

                if (!method_exists($controller, $method)) {
                    throw new Exception("Method {$method} not found in controller {$controllerClass}.");
                }

                echo call_user_func_array([$controller, $method], $params);
                return;
            }

            throw new Exception('Invalid route handler type.');
        };

        // Apply middleware stack
        foreach (array_reverse($middlewareStack) as $middlewareClass) {
            $instance = new $middlewareClass();
            $previousNext = $next;
            $next = fn() => $instance->handle($this->request, $this->response, $previousNext);
        }

        $next();
    }

    // ================================================================
    // Custom 404 Page
    // ================================================================
    private function render404(): void
    {
        $this->response->setStatusCode(404);

        $viewPath = dirname(__DIR__, 2) . '/resources/views/error/404.php';

        if (file_exists($viewPath)) {
            include $viewPath;
            return;
        }

        echo "<h1>404 - Page Not Found</h1>";
    }

    // ================================================================
    // Helpers
    // ================================================================
    private function convertToRegex(string $route): string
    {
        $pattern = preg_replace('#\{([^}]+)\}#', '([^/]+)', $route);
        return '#^' . $pattern . '$#';
    }
}

/**
 * Class RouteConfig
 * --------------------------------------------------------
 * Stores route configuration and allows middleware chaining
 * --------------------------------------------------------
 */
final class RouteConfig
{
    private array $config;

    public function __construct(array $config)
    {
        $this->config = $config;
    }

    public function middleware(string|array $middleware): self
    {
        $middleware = is_array($middleware) ? $middleware : [$middleware];
        $this->config['middleware'] = array_merge($this->config['middleware'] ?? [], $middleware);
        return $this;
    }

    public function getMiddleware(): array
    {
        return $this->config['middleware'] ?? [];
    }

    public function getHandler(): callable|string|array
    {
        return $this->config['handler'];
    }
}
