<?php

namespace App\Core;

use App\Core\Request;
use App\Core\Response;

/**
 * Class Router
 * --------------------------------------------------------
 * Handles route registration, matching, and dispatching.
 * Supports dynamic routes like /users/{id}.
 * --------------------------------------------------------
 */
class Router
{
    protected Request $request;
    protected Response $response;

    /**
     * Route storage: ['get' => [...], 'post' => [...]]
     *
     * @var array
     */
    protected array $routes = [
        'get' => [],
        'post' => []
    ];

    protected array $middleware = [];

    /**
     * Router Constructor
     */
    public function __construct(Request $request, Response $response)
    {
        $this->request  = $request;
        $this->response = $response;
    }

    /**
     * Register GET route
     *
     * @param string $path
     * @param callable|string $handler
     * @return self
     */
    public function get(string $path, $handler): self
    {
        $this->routes['get'][$path] = $handler;
        return $this;
    }

    /**
     * Register POST route
     *
     * @param string $path
     * @param callable|string $handler
     * @return self
     */
    public function post(string $path, $handler): self
    {
        $this->routes['post'][$path] = $handler;
        return $this;
    }

    /**
     * Resolve and dispatch current route
     */
    public function resolve(): void
    {
        $method = $this->request->method();
        $currentPath = $this->request->path();

        // First check static routes
        if (isset($this->routes[$method][$currentPath])) {
            $handler = $this->routes[$method][$currentPath];
            $this->executeHandler($handler);
            return;
        }

        // Check dynamic routes
        foreach ($this->routes[$method] as $route => $handler) {
            $pattern = $this->convertToRegex($route);
            if (preg_match($pattern, $currentPath, $matches)) {
                array_shift($matches); // remove full match
                $this->executeHandler($handler, $matches);
                return;
            }
        }

        // No route found -> 404
        $this->response->setStatusCode(404);
        echo "404 - Page Not Found";
    }

    /**
     * Convert route definitions like /users/{id}
     * into regex patterns.
     */
    protected function convertToRegex(string $route): string
    {
        $pattern = preg_replace('#\{([^}]+)\}#', '([^/]+)', $route);
        return '#^' . $pattern . '$#';
    }

    /**
     * Execute controller or closure
     *
     * @param mixed $handler
     * @param array $params
     */
    protected function executeHandler($handler, array $params = []): void
    {
        // Define the final controller execution
        $controllerExecution = function () use ($handler, $params) {
            // Case 1: closure function
            if (is_callable($handler)) {
                echo call_user_func_array($handler, $params);
                return;
            }

            // Case 2: Controller@method string
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

            throw new \Exception("Invalid route handler type.");
        };

        // If no middleware defined, just execute controller/closure
        if (empty($this->middleware)) {
            $controllerExecution();
            return;
        }

        // Wrap middleware stack
        $next = $controllerExecution;
        $stack = array_reverse($this->middleware);

        foreach ($stack as $middlewareClass) {
            $middlewareInstance = new $middlewareClass();

            // Wrap the current $next into middleware handle
            $next = fn() => $middlewareInstance->handle($this->request, $this->response, $next);
        }

        // Execute middleware stack + final controller
        $next();
    }

    // Method to attach middleware to a route
    public function middleware(string|array $middlewares): self
    {
        $this->middleware = is_array($middlewares) ? $middlewares : [$middlewares];
        return $this;
    }
}
