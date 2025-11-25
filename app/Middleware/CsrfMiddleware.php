<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Core\Request;
use App\Core\Response;
use App\Core\Csrf;

final class CsrfMiddleware implements MiddlewareInterface
{
    /**
     * Handle the incoming request and validate CSRF token for POST requests.
     */
    public function handle(Request $request, Response $response, callable $next): void
    {
        // Only validate state-changing requests (POST, PUT, PATCH, DELETE)
        if (in_array($request->method(), ['post', 'put', 'patch', 'delete'], true)) {
            $token = $request->input('_csrf', null);

            if (!Csrf::validateToken($token)) {
                $response->setStatusCode(403)
                         ->text('CSRF validation failed.');
                return; // Stop further execution
            }
        }

        // Continue to next middleware or route handler
        $next();
    }
}
