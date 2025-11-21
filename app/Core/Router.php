<?php
declare(strict_types=1);

namespace App\Core;

class Router
{
    private array $routes = [];
    private array $globalMiddleware = [];

    public function get(string $path, $handler, array $middleware = []): void
    {
        $this->addRoute('GET', $path, $handler, $middleware);
    }

    public function post(string $path, $handler, array $middleware = []): void
    {
        $this->addRoute('POST', $path, $handler, $middleware);
    }

    private function addRoute(string $method, string $path, $handler, array $middleware = []): void
    {
        $this->routes[] = compact('method', 'path', 'handler', 'middleware');
    }

    /**
     * Add middleware that runs on all routes
     */
    public function middleware(array $middleware): void
    {
        $this->globalMiddleware = array_merge($this->globalMiddleware, $middleware);
    }

    public function dispatch(Request $request, Response $response): void
    {
        $method = strtoupper($request->method);
        $uri = rtrim($request->path, '/') ?: '/';

        foreach ($this->routes as $route) {
            if ($route['method'] !== $method) continue;

            $pattern = $this->convertPathToRegex($route['path']);
            if (preg_match($pattern, $uri, $matches)) {
                $params = $this->extractParams($matches);
                $handler = $route['handler'];
                $middlewareStack = array_merge($this->globalMiddleware, $route['middleware']);

                $this->runMiddleware($middlewareStack, $request, $response);

                if (is_string($handler) && strpos($handler, '@') !== false) {
                    [$controllerName, $methodName] = explode('@', $handler);
                    $controllerClass = $this->qualifyController($controllerName);
                    if (!class_exists($controllerClass)) {
                        throw new \RuntimeException("Controller {$controllerClass} not found.");
                    }
                    $controller = new $controllerClass();
                    call_user_func_array([$controller, $methodName], array_merge([$request, $response], $params));
                    return;
                } elseif (is_callable($handler)) {
                    call_user_func_array($handler, array_merge([$request, $response], $params));
                    return;
                } else {
                    throw new \RuntimeException('Invalid route handler.');
                }
            }
        }

        $response->setStatus(404);
        echo "404 Not Found";
    }

    private function runMiddleware(array $middlewareStack, Request $request, Response $response): void
    {
        foreach ($middlewareStack as $middleware) {
            if (is_callable($middleware)) {
                $middleware($request, $response);
            } elseif (is_string($middleware) && class_exists($middleware)) {
                $instance = new $middleware();
                if (method_exists($instance, 'handle')) {
                    $instance->handle($request, $response);
                }
            }
        }
    }

    private function convertPathToRegex(string $path): string
    {
        $path = rtrim($path, '/') ?: '/';
        $regex = preg_replace('#\{([a-zA-Z0-9_]+)\}#', '(?P<$1>[^/]+)', $path);
        return '#^' . $regex . '$#';
    }

    private function extractParams(array $matches): array
    {
        $params = [];
        foreach ($matches as $k => $v) {
            if (is_string($k)) {
                $params[$k] = $v;
            }
        }
        return $params;
    }

    private function qualifyController(string $name): string
    {
        if (!str_ends_with($name, 'Controller')) {
            $name .= 'Controller';
        }
        return "App\\Controllers\\{$name}";
    }
}
