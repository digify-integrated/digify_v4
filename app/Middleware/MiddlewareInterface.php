<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Core\Request;
use App\Core\Response;

/**
 * Interface MiddlewareInterface
 * --------------------------------------------------------
 * Standard interface for all middleware.
 * Each middleware must implement the handle() method.
 * --------------------------------------------------------
 */
interface MiddlewareInterface
{
    /**
     * Handle the incoming request.
     *
     * @param Request  $request  Current HTTP request
     * @param Response $response HTTP response
     * @param callable $next     Next middleware or controller
     */
    public function handle(Request $request, Response $response, callable $next): void;
}
