<?php
declare(strict_types=1);

namespace App\Core\Middleware;

use App\Core\Request;
use App\Core\Response;

class AuthMiddleware implements MiddlewareInterface
{
    public function handle(Request $request, Response $response): void
    {
        $session = app('session');
        $session->start();

        if (!$session->has('user')) {
            $response->redirect('/login');
        }
    }
}
