<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Middleware\MiddlewareInterface;
use App\Core\Request;
use App\Core\Response;

/**
 * Class AuthMiddleware
 * --------------------------------------------------------
 * Ensures the user is authenticated before accessing
 * protected routes.
 * --------------------------------------------------------
 */
final class AuthMiddleware implements MiddlewareInterface
{
    /**
     * Handle incoming request and ensure authentication.
     */
    public function handle(Request $request, Response $response, callable $next): void
    {
        // Ensure session is started
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start([
                'cookie_httponly' => true,
                'cookie_samesite' => 'Lax',
            ]);
        }

        // Check for authenticated user
        if (empty($_SESSION['user_id'])) {
            // Optional: store intended URL to redirect after login
            $_SESSION['_redirect_after_login'] = $request->path();

            $response->redirect('/login', 302);
            return; // Stop further execution
        }

        // User is authenticated → continue
        $next();
    }
}
