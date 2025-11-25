<?php

declare(strict_types=1);

use App\Core\Config;

return [

    /*
    |--------------------------------------------------------------------------
    | Default Database Connection Name
    |--------------------------------------------------------------------------
    */
    'default' => Config::env('DB_CONNECTION', 'mysql'),

    /*
    |--------------------------------------------------------------------------
    | Database Connections
    |--------------------------------------------------------------------------
    */
    'connections' => [

        'mysql' => [
            'driver'    => 'mysql',
            'host'      => Config::env('DB_HOST', '127.0.0.1'),
            'port'      => Config::env('DB_PORT', '3306'),
            'database'  => Config::env('DB_NAME', 'digify_v4'),
            'username'  => Config::env('DB_USER', 'root'),
            'password'  => Config::env('DB_PASS', ''),
            'charset'   => Config::env('DB_CHARSET', 'utf8mb4'),
            'collation' => Config::env('DB_COLLATION', 'utf8mb4_unicode_ci'),

            /*
            |--------------------------------------------------------------------------
            | PDO Options (Hardened)
            |--------------------------------------------------------------------------
            */
            'options' => [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_PERSISTENT         => false,
                PDO::ATTR_EMULATE_PREPARES   => false,     // Security: use real prepared statements
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
            ],
        ],

    ],
];
