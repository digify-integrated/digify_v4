<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Middleware\MiddlewareInterface;
use App\Core\Request;
use App\Core\Response;
use App\Core\Csrf;

final class CsrfMiddleware implements MiddlewareInterface
{
    /**
     * Handle incoming request and validate CSRF token
     * for state-changing HTTP methods.
     */
    public function handle(Request $request, Response $response, callable $next): void
    {
        // Only validate CSRF for state-changing requests
        $stateChangingMethods = ['post', 'put', 'patch', 'delete'];

        if (in_array($request->method(), $stateChangingMethods, true)) {
            $token = $request->input('_csrf', null);

            if (!Csrf::validateToken($token)) {
                $response->setStatusCode(403)
                         ->text('CSRF validation failed.');
                return; // Stop execution on invalid token
            }
        }

        // Continue to next middleware or route handler
        $next();
    }
}
