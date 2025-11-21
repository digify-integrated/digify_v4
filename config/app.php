<?php
return [
    'name' => $_ENV['APP_NAME'] ?? 'digify_v4',
    'env'  => $_ENV['APP_ENV'] ?? 'production',
    'debug'=> isset($_ENV['APP_DEBUG']) ? filter_var($_ENV['APP_DEBUG'], FILTER_VALIDATE_BOOLEAN) : false,
    'url'  => $_ENV['APP_URL'] ?? 'http://localhost'
];
