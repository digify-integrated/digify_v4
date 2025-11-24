<?php

use App\Core\App;

// --------------------------------------------------------
// Example route definitions
// --------------------------------------------------------

// Home page
$app->get('/', 'AuthController@index');

// About page using closure
$app->get('/about', function () {
    return 'This is the About page of digify_v4.';
});

// Dynamic route example
$app->get('/users/{id}', function ($id) {
    return "User ID: " . $id;
});
