<?php

declare(strict_types=1);

namespace App\Core;

use App\Core\Request;
use App\Core\Response;
use Exception;

/**
 * Class Router
 * --------------------------------------------------------
 * Handles HTTP routing with support for:
 * - Static and dynamic routes
 * - Route-specific middleware
 * - Global middleware
 * - Route groups with prefix and shared middleware
 * --------------------------------------------------------
 */
final class Router
{
    private Request $request;
    private Response $response;

    /** @var array<string, array<string, array>> */
    private array $routes = [
        'get'    => [],
        'post'   => [],
        'put'    => [],
        'delete' => [],
    ];

    /** @var array<int, class-string> */
    private array $globalMiddleware = [];

    /** @var array<string, mixed> */
    private array $currentGroup = [];

    public function __construct(Request $request, Response $response)
    {
        $this->request  = $request;
        $this->response = $response;
    }

    // --------------------------------------------------------
    // Route Registration
    // --------------------------------------------------------

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

    public function delete(string $path, callable|string|array $handler): RouteConfig
    {
        return $this->addRoute('delete', $path, $handler);
    }

    private function addRoute(string $method, string $path, callable|string|array $handler): RouteConfig
    {
        if (!empty($this->currentGroup['prefix'])) {
            $path = rtrim($this->currentGroup['prefix'], '/') . '/' . ltrim($path, '/');
        }

        $this->routes[$method][$path] = [
            'handler'    => $handler,
            'middleware' => $this->currentGroup['middleware'] ?? [],
        ];

        return new RouteConfig($this->routes[$method][$path]);
    }

    // --------------------------------------------------------
    // Route Groups
    // --------------------------------------------------------

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

    // --------------------------------------------------------
    // Global Middleware
    // --------------------------------------------------------

    public function addGlobalMiddleware(string $middlewareClass): void
    {
        $this->globalMiddleware[] = $middlewareClass;
    }

    // --------------------------------------------------------
    // Route Resolution
    // --------------------------------------------------------

    public function resolve(): void
    {
        $method      = $this->request->method();
        $currentPath = $this->request->path();

        foreach ($this->routes[$method] ?? [] as $route => $config) {
            if (preg_match($this->convertToRegex($route), $currentPath, $matches)) {
                array_shift($matches);
                $this->dispatch($config, $matches);
                return;
            }
        }

        $this->response->setStatusCode(404)->send('404 - Page Not Found');
    }

    // --------------------------------------------------------
    // Dispatch with Middleware
    // --------------------------------------------------------

    private function dispatch(array $routeConfig, array $params): void
    {
        $handler = $routeConfig['handler'];

        $controllerExecution = function (): void {
            $handler = func_get_arg(0);
            $params  = func_get_arg(1);

            if (is_callable($handler)) {
                echo call_user_func_array($handler, $params);
                return;
            }

            if (is_string($handler)) {
                [$controllerName, $method] = explode('@', $handler);
                $controllerClass = "App\\Controllers\\$controllerName";

                if (!class_exists($controllerClass)) {
                    throw new Exception("Controller $controllerClass not found.");
                }

                $controller = new $controllerClass();

                if (!method_exists($controller, $method)) {
                    throw new Exception("Method $method not found in controller $controllerClass.");
                }

                echo call_user_func_array([$controller, $method], $params);
                return;
            }

            throw new Exception('Invalid route handler type.');
        };

        $middlewareStack = array_merge($this->globalMiddleware, $routeConfig['middleware'] ?? []);
        $next            = fn() => $controllerExecution($handler, $params);

        foreach (array_reverse($middlewareStack) as $middlewareClass) {
            if (!class_exists($middlewareClass)) {
                throw new Exception("Middleware $middlewareClass not found.");
            }

            $instance = new $middlewareClass();
            $previousNext = $next;
            $next = fn() => $instance->handle($this->request, $this->response, $previousNext);
        }

        $next();
    }

    // --------------------------------------------------------
    // Helpers
    // --------------------------------------------------------

    private function convertToRegex(string $route): string
    {
        $pattern = preg_replace('#\{([^}]+)\}#', '([^/]+)', $route);
        return '#^' . $pattern . '$#';
    }
}

/**
 * Class RouteConfig
 * --------------------------------------------------------
 * Allows chaining ->middleware() on route definitions
 * --------------------------------------------------------
 */
final class RouteConfig
{
    private array $route;

    public function __construct(array $route)
    {
        $this->route = $route;
    }

    /**
     * @param string|array $middleware
     */
    public function middleware(string|array $middleware): self
    {
        $this->route['middleware'] = array_merge(
            $this->route['middleware'],
            is_array($middleware) ? $middleware : [$middleware]
        );

        return $this;
    }
}
