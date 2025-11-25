<?php

declare(strict_types=1);

namespace App\Core;

use PDO;
use PDOException;
use Exception;

/**
 * Class Database
 * --------------------------------------------------------
 * Singleton PDO wrapper with support for stored procedures.
 * --------------------------------------------------------
 */
final class Database
{
    private static ?self $instance = null;
    private PDO $pdo;

    /**
     * Private constructor for singleton
     */
    private function __construct(array $config = [])
    {
        $host = $config['host'] ?? $_ENV['DB_HOST'] ?? '127.0.0.1';
        $port = $config['port'] ?? $_ENV['DB_PORT'] ?? '3306';
        $dbname = $config['database'] ?? $_ENV['DB_NAME'] ?? '';
        $user = $config['username'] ?? $_ENV['DB_USER'] ?? '';
        $pass = $config['password'] ?? $_ENV['DB_PASS'] ?? '';
        $charset = $config['charset'] ?? $_ENV['DB_CHARSET'] ?? 'utf8mb4';

        $dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset={$charset}";

        try {
            $this->pdo = new PDO(
                $dsn,
                $user,
                $pass,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_PERSISTENT => false,
                ]
            );
        } catch (PDOException $e) {
            throw new Exception("Database connection failed: " . $e->getMessage());
        }
    }

    /**
     * Get singleton instance
     */
    public static function getInstance(array $config = []): self
    {
        if (self::$instance === null) {
            self::$instance = new self($config);
        }

        return self::$instance;
    }

    // --------------------------------------------------------
    // Stored Procedure Helpers
    // --------------------------------------------------------

    public function callProcedure(string $procedure, array $params = []): array
    {
        $placeholders = implode(',', array_map(fn(string $k) => ":$k", array_keys($params)));
        $sql = "CALL {$procedure}({$placeholders})";

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function callProcedureRow(string $procedure, array $params = []): ?array
    {
        $rows = $this->callProcedure($procedure, $params);
        return $rows[0] ?? null;
    }

    public function callProcedureValue(string $procedure, array $params = []): mixed
    {
        $row = $this->callProcedureRow($procedure, $params);
        return $row ? array_values($row)[0] : null;
    }

    // --------------------------------------------------------
    // Raw PDO Access
    // --------------------------------------------------------

    public function pdo(): PDO
    {
        return $this->pdo;
    }
}
