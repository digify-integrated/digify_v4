<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Csrf
 * --------------------------------------------------------
 * Handles CSRF token generation, retrieval, and validation.
 * Tokens are stored in the session and can be rotated for security.
 * --------------------------------------------------------
 */
final class Csrf
{
    private const SESSION_KEY = '_csrf_token';

    // --------------------------------------------------------
    // Session Handling
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
    // Token Generation & Retrieval
    // --------------------------------------------------------

    public static function generateToken(): string
    {
        self::ensureSession();

        $token = bin2hex(random_bytes(32));
        $_SESSION[self::SESSION_KEY] = $token;

        return $token;
    }

    public static function getToken(): string
    {
        self::ensureSession();

        return $_SESSION[self::SESSION_KEY] ?? self::generateToken();
    }

    // --------------------------------------------------------
    // Token Validation
    // --------------------------------------------------------

    public static function validateToken(?string $token): bool
    {
        self::ensureSession();

        $sessionToken = $_SESSION[self::SESSION_KEY] ?? '';

        return !empty($token) && hash_equals($sessionToken, $token);
    }

    // --------------------------------------------------------
    // Form Helper
    // --------------------------------------------------------

    public static function field(): string
    {
        $token = self::getToken();

        return sprintf(
            '<input type="hidden" name="_csrf" value="%s">',
            htmlspecialchars($token, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8')
        );
    }
}
