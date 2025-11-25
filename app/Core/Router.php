<?php

namespace App\Core;

use App\Core\Request;
use App\Core\Response;

/**
 * Enhanced Router with:
 * - Route-specific middleware
 * - Global middleware
 * - Grouped routes (prefix + shared middleware)
 */
class Router
{
    protected Request $request;
    protected Response $response;

    protected array $routes = [
        'get' => [],
        'post' => []
    ];

    protected array $globalMiddleware = [];
    protected array $currentGroup = [];

    public function __construct(Request $request, Response $response)
    {
        $this->request  = $request;
        $this->response = $response;
    }

    // ----------------------------------------
    // Route Registration
    // ----------------------------------------

    public function get(string $path, $handler)
    {
        return $this->addRoute('get', $path, $handler);
    }

    public function post(string $path, $handler)
    {
        return $this->addRoute('post', $path, $handler);
    }

    protected function addRoute(string $method, string $path, $handler)
    {
        // Apply prefix if within a group
        if (!empty($this->currentGroup['prefix'])) {
            $path = rtrim($this->currentGroup['prefix'], '/') . '/' . ltrim($path, '/');
        }

        $this->routes[$method][$path] = [
            'handler'    => $handler,
            'middleware' => $this->currentGroup['middleware'] ?? [],
        ];

        return new RouteConfig($this->routes[$method][$path]);
    }

    // ----------------------------------------
    // Route Groups
    // ----------------------------------------

    public function group(array $config, callable $callback)
    {
        $previousGroup = $this->currentGroup;

        $this->currentGroup = [
            'prefix'     => $config['prefix']     ?? ($previousGroup['prefix'] ?? ''),
            'middleware' => $config['middleware'] ?? ($previousGroup['middleware'] ?? []),
        ];

        $callback($this);

        $this->currentGroup = $previousGroup;
    }

    // ----------------------------------------
    // Global Middleware
    // ----------------------------------------

    public function addGlobalMiddleware(string $middleware)
    {
        $this->globalMiddleware[] = $middleware;
    }

    // ----------------------------------------
    // Route Resolution
    // ----------------------------------------

    public function resolve(): void
    {
        $method = $this->request->method();
        $currentPath = $this->request->path();

        foreach ($this->routes[$method] ?? [] as $route => $config) {
            $pattern = $this->convertToRegex($route);

            if (preg_match($pattern, $currentPath, $matches)) {
                array_shift($matches);
                $this->dispatch($config, $matches);
                return;
            }
        }

        $this->response->setStatusCode(404);
        echo "404 - Page Not Found";
    }

    // ----------------------------------------
    // Dispatch With Middleware
    // ----------------------------------------

    protected function dispatch(array $routeConfig, array $params)
    {
        $handler = $routeConfig['handler'];

        $controllerExecution = function () use ($handler, $params) {
            if (is_callable($handler)) {
                echo call_user_func_array($handler, $params);
                return;
            }

            if (is_string($handler)) {
                [$controllerName, $method] = explode('@', $handler);

                $controllerClass = "App\\Controllers\\$controllerName";

                if (!class_exists($controllerClass)) {
                    throw new \Exception("Controller $controllerClass not found.");
                }

                $controller = new $controllerClass();

                if (!method_exists($controller, $method)) {
                    throw new \Exception("Method $method not found in controller $controllerClass.");
                }

                echo call_user_func_array([$controller, $method], $params);
                return;
            }
        };

        // Merge global + route middleware
        $middlewareStack = array_merge(
            $this->globalMiddleware,
            $routeConfig['middleware'] ?? []
        );

        $next = $controllerExecution;

        foreach (array_reverse($middlewareStack) as $middlewareClass) {
            $instance = new $middlewareClass;
            $next = fn() => $instance->handle($this->request, $this->response, $next);
        }

        $next();
    }

    // ----------------------------------------
    // Helpers
    // ----------------------------------------

    protected function convertToRegex(string $route): string
    {
        $pattern = preg_replace('#\{([^}]+)\}#', '([^/]+)', $route);
        return '#^' . $pattern . '$#';
    }
}

/**
 * Allows chaining ->middleware()
 */
class RouteConfig
{
    public array $route;

    public function __construct(array &$route)
    {
        $this->route = &$route;
    }

    public function middleware(string|array $middleware): self
    {
        $this->route['middleware'] = array_merge(
            $this->route['middleware'],
            is_array($middleware) ? $middleware : [$middleware]
        );

        return $this;
    }
}
