<?php

namespace App\Middleware;

class CsrfMiddleware
{
    public function handle($request, $response, $next)
    {
        session_start();

        // Only validate POST
        if ($request->method() === 'POST') {

            $token = $_POST['_csrf'] ?? null;                 // form field
            $sessionToken = $_SESSION['csrf_token'] ?? null;  // FIXED name

            if (!$token || !$sessionToken || !hash_equals($sessionToken, $token)) {
                $response->setStatusCode(403);
                echo "CSRF validation failed.";
                return; // Stop execution
            }
        }

        return $next(); // Continue to next middleware or route handler
    }
}
