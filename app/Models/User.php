<?php
declare(strict_types=1);

namespace App\Models;

class User
{
    private static array $users = [
        // username => password (hashed)
        'admin' => '$2y$10$N9qo8uLOickgx2ZMRZo4i.eJb8gC/ov5F5Xr.5m5l1X2flFXTpt1G', // password: "password"
    ];

    public static function findByUsername(string $username): ?array
    {
        if (isset(self::$users[$username])) {
            return [
                'username' => $username,
                'password' => self::$users[$username]
            ];
        }
        return null;
    }
}
