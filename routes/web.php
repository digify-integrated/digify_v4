<?php

use App\Middleware\AuthMiddleware;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/

// Home & auth pages
$app->get('/', 'AuthController@index');
$app->get('/account-security/forgot', 'AuthController@forgot');
$app->get('/register', 'AuthController@register');

// About page using closure
$app->get('/about', fn() => 'This is the About page of digify_v4.');

// 404 page
$app->get('/404', 'AuthController@error');

// Authentication POST route (CSRF automatically applied)
$app->post('/authenticate', 'AuthController@authenticate');

/*
|--------------------------------------------------------------------------
| Authenticated Routes
|--------------------------------------------------------------------------
| All routes in this group require user authentication
*/
$app->group(['middleware' => [AuthMiddleware::class]], function($app) {

    // Dynamic user route
    $app->get('/users/{id}', 'AuthController@test');

    // Profile update (POST) – CSRF automatically handled
    $app->post('/profile/update', 'UserController@updateProfile');

    /*
    |--------------------------------------------------------------------------
    | Admin Route Group
    |--------------------------------------------------------------------------
    */
    $app->group(['prefix' => '/admin'], function($app) {
        $app->get('/dashboard', fn() => 'Admin Dashboard');
        $app->get('/settings', fn() => 'Admin Settings Page');
        $app->post('/settings/save', 'AdminController@saveSettings'); // CSRF applied automatically
    });
});
