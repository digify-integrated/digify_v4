<?php

namespace App\Controllers;

use App\Core\Controller;

class HomeController extends Controller
{
    /**
     * Home page
     */
    public function index(): void
    {
        $this->view('home/index', ['name' => 'Lawrence']);
    }
}
