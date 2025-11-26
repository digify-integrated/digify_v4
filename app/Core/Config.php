<?php

declare(strict_types=1);

namespace App\Core;

use InvalidArgumentException;

final class Config
{
    private function __construct()
    {
        // Prevent instantiation
    }

    // ================================================================
    // Get environment variable as string
    // ================================================================
    public static function string(string $key, ?string $default = null): string
    {
        $value = self::env($key);
        if ($value === null || trim($value) === '') {
            if ($default !== null) {
                return $default;
            }
            throw new InvalidArgumentException("Configuration key '{$key}' is required and missing.");
        }
        return $value;
    }

    // ================================================================
    // Get environment variable as boolean
    // ================================================================
    public static function bool(string $key, bool $default = false): bool
    {
        $value = self::env($key);
        if ($value === null) {
            return $default;
        }

        $result = filter_var($value, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);
        return $result ?? $default;
    }

    // ================================================================
    // Get environment variable as integer
    // ================================================================
    public static function int(string $key, int $default = 0): int
    {
        $value = self::env($key);
        return is_numeric($value) ? (int) $value : $default;
    }

    // ================================================================
    // Get environment variable with restricted enum values
    // ================================================================
    public static function enum(string $key, array $allowedValues, string $default): string
    {
        $value = self::env($key) ?? $default;

        if (!in_array($value, $allowedValues, true)) {
            throw new InvalidArgumentException(
                "Configuration key '{$key}' has invalid value '{$value}'. Allowed: " . implode(', ', $allowedValues)
            );
        }

        return $value;
    }

    // ================================================================
    // Get environment variable as valid URL
    // ================================================================
    public static function url(string $key, string $default): string
    {
        $value = self::env($key) ?? $default;

        if (!filter_var($value, FILTER_VALIDATE_URL)) {
            throw new InvalidArgumentException("Configuration key '{$key}' must be a valid URL. Got '{$value}'.");
        }

        return rtrim($value, '/');
    }

    // ================================================================
    // Get secure key (base64, min 32 bytes)
    // ================================================================
    public static function secureKey(string $key): string
    {
        $value = self::string($key);

        $decoded = base64_decode($value, true);
        if ($decoded === false || strlen($decoded) < 32) {
            throw new InvalidArgumentException(
                "Configuration key '{$key}' must be a valid base64-encoded string of at least 32 bytes."
            );
        }

        return $value;
    }

    // ================================================================
    // Raw environment getter
    // ================================================================
    private static function env(string $key): ?string
    {
        $value = $_ENV[$key] ?? getenv($key);
        return $value !== false ? $value : null;
    }
}
