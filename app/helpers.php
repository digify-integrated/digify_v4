<?php
declare(strict_types=1);

use App\Core\Container;

/**
 * app() helper - returns service from container or the container itself
 */
if (!function_exists('app')) {
    function app(?string $service = null)
    {
        $container = Container::getInstance();
        if ($service === null) {
            return $container;
        }
        return $container->get($service);
    }
}

/**
 * config() helper - simple config loader from config files
 */
if (!function_exists('config')) {
    function config(string $key, $default = null)
    {
        static $configs = [];
        [$file, $item] = explode('.', $key . '.', 2); // ensures two parts
        if (!isset($configs[$file])) {
            $path = __DIR__ . "/../config/{$file}.php";
            $configs[$file] = file_exists($path) ? require $path : [];
        }
        return $configs[$file][$item] ?? $default;
    }
}

/**
 * e() escape helper for views
 */
if (!function_exists('e')) {
    function e($value): string
    {
        return htmlspecialchars((string)$value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }
}

/**
 * Generate hidden CSRF input for forms
 */
if (!function_exists('csrf_field')) {
    function csrf_field(): string
    {
        $token = app('csrf')->getToken();
        return '<input type="hidden" name="_csrf_token" value="' . htmlspecialchars($token, ENT_QUOTES, 'UTF-8') . '">';
    }
}

/**
 * Verify CSRF token from POST request
 */
if (!function_exists('verify_csrf')) {
    function verify_csrf(): void
    {
        $request = app('request');
        $token = $request->input('_csrf_token');
        if (!app('csrf')->verify($token)) {
            http_response_code(403);
            echo 'CSRF verification failed.';
            exit;
        }
    }
}

/**
 * view() helper - render a PHP view template
 */
if (!function_exists('view')) {
    function view(string $template, array $data = []): string
    {
        $file = __DIR__ . '/Views/' . $template . '.php';

        if (!file_exists($file)) {
            throw new \RuntimeException("View file {$file} not found.");
        }

        extract($data, EXTR_SKIP);

        ob_start();
        include $file;
        return ob_get_clean();
    }
}

/**
 * redirect() helper - send a HTTP redirect
 */
if (!function_exists('redirect')) {
    function redirect(string $url): void
    {
        header("Location: {$url}");
        exit;
    }
}
