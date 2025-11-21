<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Core\Request;
use App\Core\Response;
use App\Models\User;

class AuthController
{
    public function showLogin(Request $request, Response $response): void
    {
        echo view('auth/login', ['title' => 'Login']);
    }

    public function login(Request $request, Response $response): void
    {
        // CSRF is automatically checked by middleware
        $username = $request->input('username');
        $password = $request->input('password');

        $user = User::findByUsername($username);

        if (!$user || !password_verify($password, $user['password'])) {
            echo view('auth/login', [
                'title' => 'Login',
                'error' => 'Invalid credentials'
            ]);
            return;
        }

        // Login successful, store in session
        $session = app('session');
        $session->start();
        $session->set('user', ['username' => $user['username']]);

        $response->redirect('/dashboard');
    }

    public function logout(Request $request, Response $response): void
    {
        $session = app('session');
        $session->start();
        $session->remove('user');

        $response->redirect('/login');
    }

    public function dashboard(Request $request, Response $response): void
    {
        $session = app('session');
        $session->start();
        $user = $session->get('user');

        if (!$user) {
            $response->redirect('/login');
            return;
        }

        echo view('auth/dashboard', [
            'title' => 'Dashboard',
            'user' => $user
        ]);
    }
}
