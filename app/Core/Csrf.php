<?php

namespace App\Core;

class Csrf
{
    public static function generateToken(): string
    {
        if (!isset($_SESSION)) {
            session_start();
        }

        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }

        return $_SESSION['csrf_token'];
    }

    public static function getToken(): string
    {
        if (!isset($_SESSION)) {
            session_start();
        }
        return $_SESSION['csrf_token'] ?? self::generateToken();
    }

    public static function validateToken($token): bool
    {
        if (!isset($_SESSION)) {
            session_start();
        }
        return isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
    }
}
