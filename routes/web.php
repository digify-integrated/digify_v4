<?php

use App\Middleware\CsrfMiddleware;
use App\Middleware\AuthMiddleware;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/

// Home page
$app->get('/', 'AuthController@index');
$app->get('/account-security/forgot', 'AuthController@forgot');
$app->get('/register', 'AuthController@register');

// About page using a closure
$app->get('/about', function (): string {
    return 'This is the About page of digify_v4.';
});

// Login POST route with CSRF protection
$app->post('/login', 'AuthController@login')
    ->middleware(CsrfMiddleware::class);

// Dynamic user route with authentication
$app->get('/users/{id}', 'AuthController@test')
    ->middleware(AuthMiddleware::class);

/*
|--------------------------------------------------------------------------
| Admin Route Group
|--------------------------------------------------------------------------
| Routes with shared prefix and middleware
*/
$app->group([
    'prefix' => '/admin',
    'middleware' => [AuthMiddleware::class, CsrfMiddleware::class],
], function ($app) {
    $app->get('/dashboard', function (): string {
        return 'Admin Dashboard';
    });

    $app->get('/settings', function (): string {
        return 'Admin Settings Page';
    });

    $app->post('/settings/save', 'AdminController@saveSettings');
});

/*
|--------------------------------------------------------------------------
| Routes with Multiple Middlewares
|--------------------------------------------------------------------------
*/
$app->post('/profile/update', 'UserController@updateProfile')
    ->middleware([AuthMiddleware::class, CsrfMiddleware::class]);
