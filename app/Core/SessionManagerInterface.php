<?php
declare(strict_types=1);

namespace App\Core;

interface SessionManagerInterface
{
    public function start(): void;
    public function get(string $key, $default = null);
    public function set(string $key, $value): void;
    public function has(string $key): bool;
    public function remove(string $key): void;
    public function regenerate(bool $deleteOldSession = true): void;
    public function destroy(): void;
}
