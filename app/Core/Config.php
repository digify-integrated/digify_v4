<?php

declare(strict_types=1);

namespace App\Core;

final class Config
{
    public static function env(string $key, ?string $default = null): ?string
    {
        $value = $_ENV[$key] ?? getenv($key);
        return $value !== false ? $value : $default;
    }

    public static function bool(string $key, bool $default = false): bool
    {
        $value = self::env($key);

        if ($value === null) {
            return $default;
        }

        return filter_var($value, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE) ?? $default;
    }

    public static function int(string $key, int $default = 0): int
    {
        $value = self::env($key);
        return is_numeric($value) ? (int) $value : $default;
    }
}
