<?php
declare(strict_types=1);

namespace App\Core;

class Csrf
{
    private SessionManagerInterface $session;
    private string $tokenKey = '_csrf_token';

    public function __construct(SessionManagerInterface $session)
    {
        $this->session = $session;
    }

    /**
     * Generate a new CSRF token and store in session
     */
    public function generate(): string
    {
        $this->session->start();
        $token = bin2hex(random_bytes(32));
        $this->session->set($this->tokenKey, $token);
        return $token;
    }

    /**
     * Get existing token or generate a new one
     */
    public function getToken(): string
    {
        $this->session->start();
        $token = $this->session->get($this->tokenKey);
        if (!$token) {
            $token = $this->generate();
        }
        return $token;
    }

    /**
     * Verify token from request
     */
    public function verify(string $token): bool
    {
        $this->session->start();
        $stored = $this->session->get($this->tokenKey);
        if (!$stored || !hash_equals($stored, $token)) {
            return false;
        }
        // Optionally regenerate token after verification
        $this->generate();
        return true;
    }
}
