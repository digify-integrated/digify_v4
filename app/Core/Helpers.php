<?php

namespace App\Core;

/**
 * Class Helpers
 * --------------------------------------------------------
 * Global helper functions for common tasks.
 * You can add more helpers here as your project grows.
 * --------------------------------------------------------
 */
class Helpers
{
    /**
     * Generate a URL based on base path
     *
     * @param string $path
     * @return string
     */
    public static function url(string $path = ''): string
    {
        $baseUrl = $_ENV['APP_URL'] ?? '';
        $path = ltrim($path, '/');
        return rtrim($baseUrl, '/') . '/' . $path;
    }

    /**
     * Escape output for HTML
     *
     * @param string $string
     * @return string
     */
    public static function e(string $string): string
    {
        return htmlspecialchars($string, ENT_QUOTES, 'UTF-8');
    }

    /**
     * Dump and die (for debugging)
     *
     * @param mixed $data
     */
    public static function dd($data): void
    {
        echo '<pre>';
        var_dump($data);
        echo '</pre>';
        die;
    }

    /**
     * Simple redirect helper
     *
     * @param string $url
     */
    public static function redirect(string $url): void
    {
        header("Location: $url");
        exit;
    }

    public static function baseUrl(string $path = ''): string
    {
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https://" : "http://";
        $host = $_SERVER['HTTP_HOST'];

        // This auto-detects your app folder (e.g., /digify_v4)
        $scriptDir = str_replace('/index.php', '', $_SERVER['SCRIPT_NAME']);

        return rtrim($protocol . $host . $scriptDir, '/') . '/' . ltrim($path, '/');
    }
}
