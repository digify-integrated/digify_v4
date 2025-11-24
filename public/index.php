<?php

// --------------------------------------------------------
// Load Composer Autoload
// --------------------------------------------------------
require_once __DIR__ . '/../vendor/autoload.php';

use App\Core\App;
use App\Core\ErrorHandler;
use Dotenv\Dotenv;

// --------------------------------------------------------
// Load Environment Variables (.env)
// --------------------------------------------------------
$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->load();

// --------------------------------------------------------
// Register Custom Error Handler
// --------------------------------------------------------
$errorHandler = new ErrorHandler();
$errorHandler->register();

// --------------------------------------------------------
// Initialize Application Kernel
// --------------------------------------------------------
$app = new App();

// --------------------------------------------------------
// Load Routes
// --------------------------------------------------------
require_once dirname(__DIR__) . '/routes/web.php';

// --------------------------------------------------------
// Dispatch Incoming Request
// --------------------------------------------------------
$app->run();
