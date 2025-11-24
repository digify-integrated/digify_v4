<?php

namespace App\Core;

use PDO;
use PDOException;

/**
 * Class Database
 * --------------------------------------------------------
 * Lightweight PDO wrapper with support for
 * prepared statements and stored procedures.
 * Singleton pattern ensures a single DB connection.
 * --------------------------------------------------------
 */
class Database
{
    private static ?Database $instance = null;
    private PDO $pdo;

    /**
     * Private constructor to prevent direct instantiation.
     */
    private function __construct()
    {
        $host = $_ENV['DB_HOST'] ?? '127.0.0.1';
        $port = $_ENV['DB_PORT'] ?? '3306';
        $dbname = $_ENV['DB_NAME'] ?? '';
        $username = $_ENV['DB_USER'] ?? '';
        $password = $_ENV['DB_PASS'] ?? '';

        $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";

        try {
            $this->pdo = new PDO($dsn, $username, $password, [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_PERSISTENT         => false,
            ]);
        } catch (PDOException $e) {
            throw new \Exception("Database connection failed: " . $e->getMessage());
        }
    }

    /**
     * Get the singleton instance of the Database.
     *
     * @return Database
     */
    public static function getInstance(): Database
    {
        if (static::$instance === null) {
            static::$instance = new Database();
        }
        return static::$instance;
    }

    /**
     * Run a SELECT query and return all rows.
     *
     * @param string $sql
     * @param array $params
     * @return array
     */
    public function fetchAll(string $sql, array $params = []): array
    {
        $statement = $this->pdo->prepare($sql);
        $statement->execute($params);

        return $statement->fetchAll();
    }

    /**
     * Run a SELECT query and return a single row.
     *
     * @param string $sql
     * @param array $params
     * @return array|null
     */
    public function fetch(string $sql, array $params = []): ?array
    {
        $statement = $this->pdo->prepare($sql);
        $statement->execute($params);

        $result = $statement->fetch();
        return $result ?: null;
    }

    /**
     * Run INSERT/UPDATE/DELETE queries.
     *
     * @param string $sql
     * @param array $params
     * @return int Number of affected rows
     */
    public function execute(string $sql, array $params = []): int
    {
        $statement = $this->pdo->prepare($sql);
        $statement->execute($params);

        return $statement->rowCount();
    }

    /**
     * Call a stored procedure and return the results.
     *
     * @param string $procedureName
     * @param array $params
     * @return array
     */
    public function callProcedure(string $procedureName, array $params = []): array
    {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        $sql = "CALL $procedureName($placeholders)";

        $statement = $this->pdo->prepare($sql);
        $statement->execute(array_values($params));

        return $statement->fetchAll();
    }

    /**
     * Get the raw PDO connection (if needed).
     *
     * @return PDO
     */
    public function pdo(): PDO
    {
        return $this->pdo;
    }
}
