<?php
/** @var \App\Core\Router $router */
use App\Core\Middleware\AuthMiddleware;

$router = app('router');

// Home
$router->get('/', 'HomeController@index');
$router->get('/user/{id}', function($request, $response, $id) {
    echo "User ID: " . htmlspecialchars($id, ENT_QUOTES, 'UTF-8');
});

// Form submission route
$router->post('/submit', function($request, $response) {
    $name = $request->input('name');
    echo "Form submitted successfully! Name: " . htmlspecialchars($name, ENT_QUOTES, 'UTF-8');
});


$router->get('/login', 'AuthController@showLogin');
$router->post('/login', 'AuthController@login');
$router->get('/logout', 'AuthController@logout');
$router->get('/dashboard', 'AuthController@dashboard', [AuthMiddleware::class]);




// Example dynamic route:
// $router->get('/user/{id}', function($request, $response, $id) {
//     echo "User ID: " . htmlspecialchars($id, ENT_QUOTES, 'UTF-8');
// });
