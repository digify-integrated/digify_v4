<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Security
 * --------------------------------------------------------
 * Core security utilities for:
 * - Encryption/Decryption
 * - Token hashing
 * - OTP generation
 * - Masking sensitive data
 * --------------------------------------------------------
 */
final class Security
{
    /**
     * Retrieve the encryption key from environment
     */
    private static function getKey(): string
    {
        $key = $_ENV['APP_KEY'] ?? '';
        if ($key === '') {
            throw new \RuntimeException('APP_KEY is not defined in environment.');
        }
        return $key;
    }

    // ================================================================
    // TOKEN HASHING & OTP
    // ================================================================

    public static function hashToken(string $token): string
    {
        $peppered = hash_hmac('sha256', $token, self::getKey());
        return password_hash($peppered, PASSWORD_DEFAULT);
    }

    public static function verifyToken(string $token, string $hash): bool
    {
        $peppered = hash_hmac('sha256', $token, self::getKey());
        return password_verify($peppered, $hash);
    }

    public static function generateOtp(int $digits = 6): string
    {
        $max = (10 ** $digits) - 1;
        return str_pad((string) random_int(0, $max), $digits, '0', STR_PAD_LEFT);
    }

    // ================================================================
    // ENCRYPTION / DECRYPTION
    // ================================================================

    public static function encrypt(string $data): string|false
    {
        if (trim($data) === '') return false;

        $ivLength = openssl_cipher_iv_length('aes-256-cbc');
        $iv = random_bytes($ivLength);

        $cipher = openssl_encrypt(
            $data,
            'aes-256-cbc',
            self::getKey(),
            OPENSSL_RAW_DATA,
            $iv
        );

        return $cipher ? rawurlencode(base64_encode($iv . $cipher)) : false;
    }

    public static function decrypt(string $ciphertext): string|false
    {
        $decoded = base64_decode(rawurldecode($ciphertext), true);
        if (!$decoded) return false;

        $ivLength = openssl_cipher_iv_length('aes-256-cbc');
        if (strlen($decoded) <= $ivLength) return false;

        $iv = substr($decoded, 0, $ivLength);
        $cipher = substr($decoded, $ivLength);

        return openssl_decrypt($cipher, 'aes-256-cbc', self::getKey(), OPENSSL_RAW_DATA, $iv) ?: false;
    }

    // ================================================================
    // DATA MASKING
    // ================================================================

    public static function obscureEmail(string $email): string
    {
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) return '[invalid email]';

        [$user, $domain] = explode('@', strtolower(trim($email)), 2);

        $maskedUser = strlen($user) <= 2
            ? str_repeat('*', strlen($user))
            : substr($user, 0, 1) . str_repeat('*', strlen($user) - 2) . substr($user, -1);

        $parts = explode('.', $domain);
        $tld = array_pop($parts);
        $maskedDomain = '';
        foreach ($parts as $part) {
            $maskedDomain .= substr($part, 0, 2) . str_repeat('*', max(0, strlen($part) - 2)) . '.';
        }
        $maskedDomain .= $tld;

        return "{$maskedUser}@{$maskedDomain}";
    }

    public static function obscureCardNumber(string $cardNumber): string
    {
        $last4 = substr($cardNumber, -4);
        $masked = str_repeat('*', max(0, strlen($cardNumber) - 4));
        $maskedGrouped = implode(' ', str_split($masked, 4));
        return trim($maskedGrouped . ' ' . $last4);
    }
}
