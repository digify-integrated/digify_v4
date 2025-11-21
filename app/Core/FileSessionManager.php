<?php
declare(strict_types=1);

namespace App\Core;

class FileSessionManager implements SessionManagerInterface
{
    private bool $started = false;
    private int $lifetime;

    public function __construct()
    {
        $this->lifetime = (int) ($_ENV['SESSION_LIFETIME'] ?? 604800); // default 7 days
        // set session cookie params for long sessions (POS future-proofing)
        session_set_cookie_params([
            'lifetime' => $this->lifetime,
            'path' => '/',
            'secure' => isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
            'httponly' => true,
            'samesite' => 'Lax'
        ]);
    }

    public function start(): void
    {
        if ($this->started === false) {
            if (session_status() === PHP_SESSION_NONE) {
                session_start();
            }
            $this->started = true;
        }
    }

    public function get(string $key, $default = null)
    {
        $this->start();
        return $_SESSION[$key] ?? $default;
    }

    public function set(string $key, $value): void
    {
        $this->start();
        $_SESSION[$key] = $value;
    }

    public function has(string $key): bool
    {
        $this->start();
        return array_key_exists($key, $_SESSION);
    }

    public function remove(string $key): void
    {
        $this->start();
        unset($_SESSION[$key]);
    }

    public function regenerate(bool $deleteOldSession = true): void
    {
        $this->start();
        session_regenerate_id($deleteOldSession);
    }

    public function destroy(): void
    {
        if (session_status() !== PHP_SESSION_NONE) {
            $_SESSION = [];
            if (ini_get('session.use_cookies')) {
                $params = session_get_cookie_params();
                setcookie(session_name(), '', time() - 42000,
                    $params['path'], $params['domain'] ?? '', $params['secure'], $params['httponly']);
            }
            session_destroy();
        }
        $this->started = false;
    }
}
