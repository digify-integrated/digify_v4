<?php


$app->get('/', 'AuthController@index');

$app->get('/about', function () {
    return 'This is the About page of digify_v4.';
});

$app->post('/login', 'AuthController@login')
    ->middleware('csrf');

$app->get('/users/{id}', 'AuthController@test');

/*
Group Routes

$app->group(['prefix' => '/admin', 'middleware' => [AuthMiddleware::class]], function ($router) {
    $router->get('/dashboard', 'AdminController@dashboard');
    $router->get('/users', 'AdminController@users');
});

----------------------------------

Simple Route + Middleware

$app->get('/profile', 'UserController@profile')
    ->middleware(AuthMiddleware::class);


----------------------------------

Global Middleware (e.g. CSRF)
 
$app->addGlobalMiddleware(\App\Middleware\CsrfMiddleware::class);

*/