<?php

namespace App\Core;

use App\Core\Router;
use App\Core\Request;
use App\Core\Response;
use App\Core\RouteConfig;

class App
{
    protected Router $router;
    protected Request $request;
    protected Response $response;

    public function __construct()
    {
        $this->request  = new Request();
        $this->response = new Response();
        $this->router   = new Router($this->request, $this->response);
    }

    /**
     * Register GET route
     *
     * @param string $path
     * @param callable|string $handler
     * @return RouteConfig
     */
    public function get(string $path, $handler): RouteConfig
    {
        return $this->router->get($path, $handler);
    }

    /**
     * Register POST route
     *
     * @param string $path
     * @param callable|string $handler
     * @return RouteConfig
     */
    public function post(string $path, $handler): RouteConfig
    {
        return $this->router->post($path, $handler);
    }

    /**
     * Run the application.
     */
    public function run(): void
    {
        $this->router->resolve();
    }
}
