<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Core\Request;
use App\Core\Response;

/**
 * Class AuthMiddleware
 * --------------------------------------------------------
 * Ensures the user is authenticated before allowing access
 * to protected routes.
 * --------------------------------------------------------
 */
class AuthMiddleware implements MiddlewareInterface
{
    /**
     * Handle the incoming request.
     *
     * @param Request  $request
     * @param Response $response
     * @param callable $next
     */
    public function handle(Request $request, Response $response, callable $next): void
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }

        // Example authentication check: must be logged in
        if (empty($_SESSION['user_id'])) {
            $response->redirect('/login', 302);
            return; // Stop further execution
        }

        // User is authenticated → continue to next middleware or handler
        $next();
    }
}
