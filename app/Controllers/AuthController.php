<?php

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Database;
use App\Core\Helpers;

class AuthController extends Controller
{
    protected $db;
    protected $helpers;

    public function __construct()
    {
        $this->db = Database::getInstance();
        $this->helpers = new Helpers();
        session_start();
    }
    
    public function index()
    {
        return $this->view('auth/login', [], 'auth-layout');
    }

    public function register()
    {
        return $this->view('auth/register');
    }
}
