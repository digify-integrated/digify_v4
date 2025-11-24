<?php

namespace App\Core;

use App\Core\Router;
use App\Core\Request;
use App\Core\Response;

/**
 * Class App
 * --------------------------------------------------------
 * The main application kernel.
 * Responsible for bootstrapping core components
 * and delegating route resolution to the Router.
 * --------------------------------------------------------
 */
class App
{
    /**
     * @var Router
     */
    protected Router $router;

    /**
     * @var Request
     */
    protected Request $request;

    /**
     * @var Response
     */
    protected Response $response;

    /**
     * App Constructor
     * Initializes Request, Response and Router.
     */
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
     * @return Router
     */
    public function get(string $path, $handler): Router
    {
        return $this->router->get($path, $handler);
    }

    /**
     * Register POST route
     *
     * @param string $path
     * @param callable|string $handler
     * @return Router
     */
    public function post(string $path, $handler): Router
    {
        return $this->router->post($path, $handler);
    }

    /**
     * Run the application.
     * Delegates to the Router for route resolution.
     */
    public function run(): void
    {
        $this->router->resolve();
    }
}
