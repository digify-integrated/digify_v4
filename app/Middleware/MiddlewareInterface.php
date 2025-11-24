<?php

namespace App\Middleware;

use App\Core\Request;
use App\Core\Response;

interface MiddlewareInterface
{
    /**
     * Handle the incoming request.
     *
     * @param Request $request
     * @param Response $response
     * @param callable $next Next middleware or controller
     */
    public function handle(Request $request, Response $response, callable $next): void;
}
