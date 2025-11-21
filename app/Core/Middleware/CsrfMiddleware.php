<?php
declare(strict_types=1);

namespace App\Core\Middleware;

use App\Core\Request;
use App\Core\Response;

class CsrfMiddleware implements MiddlewareInterface
{
    public function handle(Request $request, Response $response): void
    {
        $method = strtoupper($request->method);

        // Only validate CSRF on state-changing requests
        if (in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'])) {
            $token = $request->input('_csrf_token');
            $csrf = app('csrf');

            if (!$csrf->verify($token)) {
                // Generate a fresh token even after failure
                $csrf->generate();

                $response->setStatus(403);
                echo 'CSRF verification failed.';
                exit;
            }
        }

        // Always generate a new token for next request
        app('csrf')->generate();
    }
}
