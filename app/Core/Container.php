<?php
declare(strict_types=1);

namespace App\Core;

class Container
{
    private static ?Container $instance = null;
    private array $bindings = [];
    private array $instances = [];

    public static function setInstance(Container $container): void
    {
        self::$instance = $container;
    }

    public static function getInstance(): Container
    {
        if (self::$instance === null) {
            self::$instance = new Container();
        }
        return self::$instance;
    }

    public function bind(string $key, callable $resolver): void
    {
        $this->bindings[$key] = $resolver;
    }

    public function get(string $key)
    {
        if (isset($this->instances[$key])) {
            return $this->instances[$key];
        }
        if (!isset($this->bindings[$key])) {
            throw new \RuntimeException("Service '{$key}' is not bound in the container.");
        }
        $this->instances[$key] = call_user_func($this->bindings[$key]);
        return $this->instances[$key];
    }
}
