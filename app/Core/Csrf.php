<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Csrf
 * --------------------------------------------------------
 * Handles CSRF token generation, retrieval, validation.
 * Supports token rotation, configurable lifetime, and safe output.
 * --------------------------------------------------------
 */
final class Csrf
{
    private const SESSION_KEY = '_csrf_token';
    private const SESSION_TIME_KEY = '_csrf_token_time';
    private const TOKEN_LENGTH = 32;

    // --------------------------------------------------------
    // Ensure session is started
    // --------------------------------------------------------
    private static function ensureSession(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start([
                'cookie_httponly' => true,
                'cookie_samesite' => 'Lax',
            ]);
        }
    }

    // --------------------------------------------------------
    // Token Generation
    // --------------------------------------------------------
    public static function generateToken(): string
    {
        self::ensureSession();

        $token = bin2hex(random_bytes(self::TOKEN_LENGTH));
        $_SESSION[self::SESSION_KEY] = $token;
        $_SESSION[self::SESSION_TIME_KEY] = time();

        return $token;
    }

    // --------------------------------------------------------
    // Retrieve current token (rotate if expired)
    // --------------------------------------------------------
    public static function getToken(int $lifetime = 3600): string
    {
        self::ensureSession();

        $token = $_SESSION[self::SESSION_KEY] ?? null;
        $created = $_SESSION[self::SESSION_TIME_KEY] ?? 0;

        if ($token === null || (time() - $created) > $lifetime) {
            return self::generateToken();
        }

        return $token;
    }

    // --------------------------------------------------------
    // Validate token
    // --------------------------------------------------------
    public static function validateToken(?string $token, int $lifetime = 3600): bool
    {
        self::ensureSession();

        $sessionToken = $_SESSION[self::SESSION_KEY] ?? '';
        $created = $_SESSION[self::SESSION_TIME_KEY] ?? 0;

        if (empty($token) || empty($sessionToken)) {
            return false;
        }

        // Check token expiration
        if ((time() - $created) > $lifetime) {
            return false;
        }

        return hash_equals($sessionToken, $token);
    }

    // --------------------------------------------------------
    // Helper for HTML forms
    // --------------------------------------------------------
    public static function field(int $lifetime = 3600): string
    {
        $token = self::getToken($lifetime);

        return sprintf(
            '<input type="hidden" name="_csrf" value="%s">',
            htmlspecialchars($token, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
        );
    }

    // --------------------------------------------------------
    // Optional: manually reset token
    // --------------------------------------------------------
    public static function reset(): void
    {
        self::ensureSession();
        unset($_SESSION[self::SESSION_KEY], $_SESSION[self::SESSION_TIME_KEY]);
    }
}
