<?php

declare(strict_types=1);

namespace App\Core;

use PDO;
use PDOException;
use Exception;

/**
 * Class Database
 * --------------------------------------------------------
 * Singleton PDO wrapper with:
 * - Prepared statements
 * - Transactions
 * - CRUD helpers
 * - Secure default settings
 * --------------------------------------------------------
 */
final class Database
{
    private static ?self $instance = null;
    private PDO $pdo;

    /**
     * Private constructor to enforce singleton pattern.
     *
     * @param array<string, string|int> $config
     */
    private function __construct(array $config = [])
    {
        $host = $config['host'] ?? $_ENV['DB_HOST'] ?? '127.0.0.1';
        $port = $config['port'] ?? $_ENV['DB_PORT'] ?? '3306';
        $dbname = $config['database'] ?? $_ENV['DB_DATABASE'] ?? '';
        $user = $config['username'] ?? $_ENV['DB_USERNAME'] ?? '';
        $pass = $config['password'] ?? $_ENV['DB_PASSWORD'] ?? '';
        $charset = $config['charset'] ?? $_ENV['DB_CHARSET'] ?? 'utf8mb4';
        $collation = $config['collation'] ?? $_ENV['DB_COLLATION'] ?? 'utf8mb4_unicode_ci';

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
                    PDO::ATTR_EMULATE_PREPARES => false, // security: use native prepared statements
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES {$charset} COLLATE {$collation}",
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

    /**
     * Expose PDO for raw queries
     */
    public function pdo(): PDO
    {
        return $this->pdo;
    }

    // --------------------------------------------------------
    // Generic Query Helpers
    // --------------------------------------------------------

    /**
     * Execute a SELECT query and return all rows
     */
    public function query(string $sql, array $params = []): array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    /**
     * Execute a SELECT query and return single row
     */
    public function fetch(string $sql, array $params = []): ?array
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        $row = $stmt->fetch();
        return $row === false ? null : $row;
    }

    /**
     * Execute an INSERT, UPDATE, or DELETE
     */
    public function execute(string $sql, array $params = []): int
    {
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->rowCount();
    }

    /**
     * Insert a row into table and return last inserted ID
     */
    public function insert(string $table, array $data): int|string
    {
        $columns = array_keys($data);
        $placeholders = array_map(fn($col) => ":$col", $columns);

        $sql = sprintf(
            "INSERT INTO `%s` (%s) VALUES (%s)",
            $table,
            implode(',', $columns),
            implode(',', $placeholders)
        );

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($data);

        return (int) $this->pdo->lastInsertId();
    }

    /**
     * Update rows in table
     */
    public function update(string $table, array $data, string $where, array $whereParams = []): int
    {
        $set = implode(',', array_map(fn($col) => "`$col` = :$col", array_keys($data)));
        $sql = sprintf("UPDATE `%s` SET %s WHERE %s", $table, $set, $where);

        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(array_merge($data, $whereParams));

        return $stmt->rowCount();
    }

    /**
     * Delete rows from table
     */
    public function delete(string $table, string $where, array $params = []): int
    {
        $sql = sprintf("DELETE FROM `%s` WHERE %s", $table, $where);
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($params);
        return $stmt->rowCount();
    }

    // --------------------------------------------------------
    // Transaction Helpers
    // --------------------------------------------------------

    public function beginTransaction(): bool
    {
        return $this->pdo->beginTransaction();
    }

    public function commit(): bool
    {
        return $this->pdo->commit();
    }

    public function rollBack(): bool
    {
        return $this->pdo->rollBack();
    }
}
