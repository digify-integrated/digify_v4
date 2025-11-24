<?php

namespace App\Middleware;

use App\Core\Request;
use App\Core\Response;
use App\Middleware\MiddlewareInterface;

class AuthMiddleware implements MiddlewareInterface
{
    public function handle(Request $request, Response $response, callable $next): void
    {
        session_start();

        // Example check: user must be logged in
        if (!isset($_SESSION['user_id'])) {
            $response->setStatusCode(302);
            header("Location: /login");
            exit;
        }

        // User authenticated → continue
        $next();
    }
}
