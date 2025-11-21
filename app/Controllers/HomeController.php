<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Response;

class HomeController extends Controller
{
    public function index(Request $request, Response $response): void
    {
        $data = [
            'title' => 'Welcome to digify_v4',
            'appName' => $_ENV['APP_NAME'] ?? 'digify_v4',
        ];
        $this->view('home', $data);
    }
}
