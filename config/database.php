<?php

declare(strict_types=1);

use App\Core\Config;
use PDO;

return [

    // ================================================================
    // Default Database Connection
    // ================================================================
    'default' => Config::enum('DB_CONNECTION', ['mysql', 'pgsql', 'sqlite', 'sqlsrv'], 'mysql'),

    // ================================================================
    // Database Connections
    // ================================================================
    'connections' => [

        'mysql' => [
            'driver'    => 'mysql',
            'host'      => Config::string('DB_HOST', '127.0.0.1'),
            'port'      => Config::int('DB_PORT', 3306),
            'database'  => Config::string('DB_DATABASE', 'digifydb'),
            'username'  => Config::string('DB_USERNAME', 'root'),
            'password'  => Config::string('DB_PASSWORD', ''),
            'charset'   => Config::string('DB_CHARSET', 'utf8mb4'),
            'collation' => Config::string('DB_COLLATION', 'utf8mb4_unicode_ci'),

            // ============================================================
            // PDO Options (Hardened)
            // ============================================================
            'options' => [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_PERSISTENT         => false,
                PDO::ATTR_EMULATE_PREPARES   => false, // Security: use real prepared statements
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
            ],
        ],

    ],

];
