<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Database;
use App\Core\Helpers;

/**
 * Class AuthController
 * --------------------------------------------------------
 * Handles authentication-related actions:
 * - Login
 * - Registration
 * - Example dynamic route
 * --------------------------------------------------------
 */
class AuthController extends Controller
{
    protected Database $db;

    public function __construct()
    {
        parent::__construct();

        $this->db = Database::getInstance();

        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }
    }

    /**
     * Show login page
     */
    public function index(): void
    {
        $this->view('auth/login', [], 'auth-layout');
    }

    /**
     * Show forgot password page
     */
    public function forgot(): void
    {
        $this->view('auth/forgot', ['title' => 'Forgot Password'], 'auth-layout');
    }

    /**
     * Show registration page
     */
    public function register(): void
    {
        $this->view('auth/register', ['title' => 'Register'], 'auth-layout');
    }

    /**
     * Example route with a dynamic parameter
     *
     * @param string|int $id
     */
    public function test(string|int $id): void
    {
        echo Helpers::e((string)$id);
    }
}
