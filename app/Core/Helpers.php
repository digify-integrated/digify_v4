<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Helpers
 * --------------------------------------------------------
 * Global helper functions for common tasks:
 * - URL & asset management
 * - CSRF helpers
 * - File uploads
 * - Logging & debugging
 * - Standardized JSON responses
 * --------------------------------------------------------
 */
final class Helpers
{
    // --------------------------------------------------------
    // URL HELPERS
    // --------------------------------------------------------

    public static function url(string $path = ''): string
    {
        $baseUrl = $_ENV['APP_URL'] ?? 'http://localhost';
        return rtrim($baseUrl, '/') . '/' . ltrim($path, '/');
    }

    public static function baseUrl(string $path = ''): string
    {
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https://' : 'http://';
        $host = $_SERVER['HTTP_HOST'] ?? 'localhost';
        $scriptDir = str_replace('/index.php', '', $_SERVER['SCRIPT_NAME'] ?? '');
        return rtrim($protocol . $host . $scriptDir, '/') . '/' . ltrim($path, '/');
    }

    public static function e(string $string): string
    {
        return htmlspecialchars($string, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    }

    public static function redirect(string $path): void
    {
        header('Location: ' . self::url($path));
        exit;
    }

    // --------------------------------------------------------
    // ASSET HELPERS
    // --------------------------------------------------------

    public static function asset(string $path): string
    {
        return self::baseUrl(ltrim($path, '/'));
    }

    public static function css(string $path, bool $cacheBust = false, bool $echo = true): ?string
    {
        $url = self::asset($path) . ($cacheBust ? '?v=' . rand() : '');
        $tag = '<link href="' . $url . '" rel="stylesheet" type="text/css">';
        if ($echo) { echo $tag; return null; }
        return $tag;
    }

    public static function js(string $path, bool $cacheBust = false, bool $module = false, bool $echo = true): ?string
    {
        $url = self::asset($path) . ($cacheBust ? '?v=' . rand() : '');
        $type = $module ? ' type="module"' : '';
        $tag = "<script src=\"$url\"$type></script>";
        if ($echo) { echo $tag; return null; }
        return $tag;
    }

    // --------------------------------------------------------
    // CSRF HELPERS
    // --------------------------------------------------------

    public static function csrfToken(): string
    {
        return Csrf::getToken();
    }

    public static function csrfField(): string
    {
        return Csrf::field();
    }

    public static function validateCsrf(?string $token): bool
    {
        return Csrf::validateToken($token);
    }

    // --------------------------------------------------------
    // FILE UPLOAD
    // --------------------------------------------------------

    public static function upload(array $file, string $folder = ''): ?string
    {
        $uploadDir = __DIR__ . '/../../storage/uploads/' . trim($folder, '/');
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0755, true);

        $filename = preg_replace('/[^a-zA-Z0-9_\.-]/', '_', basename($file['name']));
        $targetPath = $uploadDir . '/' . $filename;

        return move_uploaded_file($file['tmp_name'], $targetPath)
            ? 'storage/uploads/' . ($folder ? $folder . '/' : '') . $filename
            : null;
    }

    // --------------------------------------------------------
    // LOGGING & DEBUG
    // --------------------------------------------------------

    public static function log(string $message, string $level = 'info'): void
    {
        $logDir = __DIR__ . '/../../storage/logs';
        if (!is_dir($logDir)) mkdir($logDir, 0755, true);

        $date = date('Y-m-d H:i:s');
        file_put_contents($logDir . '/app.log', "[$date][$level] $message" . PHP_EOL, FILE_APPEND);
    }

    public static function dd(mixed $data): void
    {
        echo '<pre style="background:#f4f4f4;padding:10px;border-radius:5px;">';
        var_dump($data);
        echo '</pre>';
        exit;
    }

    // --------------------------------------------------------
    // STANDARDIZED JSON RESPONSES
    // --------------------------------------------------------

    public static function sendErrorResponse(string $title, string $message, array $additionalData = []): void
    {
        $response = array_merge([
            'success'      => false,
            'title'        => $title,
            'message'      => $message,
            'message_type' => 'error',
        ], $additionalData);

        self::sendJsonAndExit($response);
    }

    public static function sendSuccessResponse(string $title, string $message, array $additionalData = []): void
    {
        $response = array_merge([
            'success'      => true,
            'title'        => $title,
            'message'      => $message,
            'message_type' => 'success',
        ], $additionalData);

        self::sendJsonAndExit($response);
    }

    private static function sendJsonAndExit(array $data): void
    {
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
        exit;
    }
}
