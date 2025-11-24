<?php

namespace App\Core;

use PDO;
use PDOStatement;
use PDOException;

/**
 * Class Model
 * --------------------------------------------------------
 * Base abstract Model class.
 * Provides low-level database helpers + generic CRUD.
 * Extend this class for specific models.
 * --------------------------------------------------------
 */
abstract class Model
{
    /**
     * @var PDO Active PDO database connection
     */
    protected PDO $db;

    /**
     * @var string Table name for CRUD operations
     */
    protected string $table = '';

    /**
     * Model constructor.
     *
     * Initializes the PDO database connection using Database singleton.
     */
    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Low-level query executor with logging.
     *
     * @param string $query  SQL query
     * @param array  $params Params to bind
     *
     * @return PDOStatement|false
     */
    protected function query(string $query, array $params = [])
    {
        try {
            $stmt = $this->db->prepare($query);

            // Log query with masked parameters for debugging
            error_log('Executing query: ' . $this->maskQuery($query, $params));

            $stmt->execute($params);
            return $stmt;

        } catch (PDOException $e) {
            error_log('DB Query Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Fetch multiple rows.
     */
    protected function fetchAll(string $query, array $params = []): array
    {
        $stmt = $this->query($query, $params);
        return $stmt ? $stmt->fetchAll(PDO::FETCH_ASSOC) : [];
    }

    /**
     * Fetch single row.
     */
    protected function fetch(string $query, array $params = []): ?array
    {
        $stmt   = $this->query($query, $params);
        $result = $stmt ? $stmt->fetch(PDO::FETCH_ASSOC) : null;

        return $result !== false ? $result : null;
    }

    /**
     * ------------------------
     * GENERIC CRUD OPERATIONS
     * ------------------------
     */

    /**
     * Get all rows from table
     */
    public function all(): array
    {
        return $this->fetchAll("SELECT * FROM {$this->table}");
    }

    /**
     * Find row by ID
     */
    public function find(int $id): ?array
    {
        return $this->fetch(
            "SELECT * FROM {$this->table} WHERE id = :id LIMIT 1",
            ['id' => $id]
        );
    }

    /**
     * Insert new record
     */
    public function create(array $data): bool
    {
        $columns = implode(",", array_keys($data));
        $placeholders = ":" . implode(",:", array_keys($data));

        $sql = "INSERT INTO {$this->table} ($columns) VALUES ($placeholders)";
        return $this->query($sql, $data) !== false;
    }

    /**
     * Update record by ID
     */
    public function update(int $id, array $data): bool
    {
        $setStr = implode(',', array_map(fn($key) => "$key = :$key", array_keys($data)));
        $data['id'] = $id;

        $sql = "UPDATE {$this->table} SET $setStr WHERE id = :id";
        return $this->query($sql, $data) !== false;
    }

    /**
     * Delete record by ID
     */
    public function delete(int $id): bool
    {
        return $this->query(
            "DELETE FROM {$this->table} WHERE id = :id",
            ['id' => $id]
        ) !== false;
    }

    /**
     * Mask parameters when logging SQL for debugging.
     */
    private function maskQuery(string $query, array $params): string
    {
        foreach ($params as $key => $value) {
            $mask = is_numeric($value) ? '[NUM]' : '[STR]';
            $placeholder = is_int($key) ? '?' : ":$key";
            $query = str_replace($placeholder, $mask, $query);
        }
        return $query;
    }
}
