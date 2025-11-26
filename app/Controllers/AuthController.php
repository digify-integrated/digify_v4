<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Helpers;
use App\Models\UserModel;

/**
 * Class AuthController
 * --------------------------------------------------------
 * Handles authentication:
 * - Login
 * - Registration
 * - Logout
 * --------------------------------------------------------
 */
final class AuthController extends Controller
{
    private UserModel $userModel;

    public function __construct()
    {
        parent::__construct();
        $this->userModel = new UserModel();

        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start([
                'cookie_httponly' => true,
                'cookie_samesite' => 'Lax',
            ]);
        }
    }

    // --------------------------------------------------------
    // Login Page
    // --------------------------------------------------------
    public function index(): void
    {
        $this->view('auth/login', ['title' => 'Login'], 'auth-layout');
    }

    // --------------------------------------------------------
    // Registration Page
    // --------------------------------------------------------
    public function register(): void
    {
        $this->view('auth/register', ['title' => 'Register'], 'auth-layout');
    }

    // --------------------------------------------------------
    // Forgot Password Page
    // --------------------------------------------------------
    public function forgot(): void
    {
        $this->view('auth/forgot', ['title' => 'Forgot Password'], 'auth-layout');
    }

    // --------------------------------------------------------
    // Authenticate User (Login)
    // --------------------------------------------------------
    public function authenticate(): void
    {
        $email    = trim($this->request->input('email'));
        $password = trim($this->request->input('password'));

        if (empty($email) || empty($password)) {
            $_SESSION['_flash_error'] = 'Email and password are required.';
            $this->response->redirect('/login');
            return;
        }

        $user = $this->userModel->authenticate($email, $password);

        if (!$user) {
            $_SESSION['_flash_error'] = 'Invalid credentials.';
            $this->response->redirect('/login');
            return;
        }

        // Login successful
        $_SESSION['user_id']    = $user['id'];
        $_SESSION['user_name']  = $user['name'];
        $_SESSION['user_email'] = $user['email'];

        // Redirect to intended page or dashboard
        $redirect = $_SESSION['_redirect_after_login'] ?? '/dashboard';
        unset($_SESSION['_redirect_after_login']);

        $this->response->redirect($redirect);
    }

    // --------------------------------------------------------
    // Register New User
    // --------------------------------------------------------
    public function store(): void
    {
        $name     = trim($this->request->input('name'));
        $email    = trim($this->request->input('email'));
        $password = trim($this->request->input('password'));
        $confirm  = trim($this->request->input('password_confirmation'));

        // Basic validation
        if (empty($name) || empty($email) || empty($password) || $password !== $confirm) {
            $_SESSION['_flash_error'] = 'Please fill all fields correctly.';
            $this->response->redirect('/register');
            return;
        }

        // Check if email already exists
        if ($this->userModel->findByEmail($email)) {
            $_SESSION['_flash_error'] = 'Email is already registered.';
            $this->response->redirect('/register');
            return;
        }

        // Hash password
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);

        // Create user
        $userId = $this->userModel->create([
            'name'     => $name,
            'email'    => $email,
            'password' => $hashedPassword,
        ]);

        // Auto-login
        $user = $this->userModel->findById($userId);
        $_SESSION['user_id']    = $user['id'];
        $_SESSION['user_name']  = $user['name'];
        $_SESSION['user_email'] = $user['email'];

        $this->response->redirect('/dashboard');
    }

    // --------------------------------------------------------
    // Logout
    // --------------------------------------------------------
    public function logout(): void
    {
        session_unset();
        session_destroy();
        $this->response->redirect('/login');
    }

    // --------------------------------------------------------
    // Example dynamic route
    // --------------------------------------------------------
    public function test(string|int $id): void
    {
        echo Helpers::e((string)$id);
    }
}
