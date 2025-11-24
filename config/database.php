<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Database Connection Name
    |--------------------------------------------------------------------------
    */
    'default' => $_ENV['DB_CONNECTION'] ?? 'mysql',

    /*
    |--------------------------------------------------------------------------
    | Database Connections
    |--------------------------------------------------------------------------
    */
    'connections' => [

        'mysql' => [
            'driver'    => 'mysql',
            'host'      => $_ENV['DB_HOST'] ?? '127.0.0.1',
            'port'      => $_ENV['DB_PORT'] ?? '3306',
            'database'  => $_ENV['DB_NAME'] ?? 'digify_v4',
            'username'  => $_ENV['DB_USER'] ?? 'root',
            'password'  => $_ENV['DB_PASS'] ?? '',
            'charset'   => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
        ],

    ],

];
