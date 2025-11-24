<?php

namespace App\Core;

use App\Core\Database;

/**
 * Class Model
 * --------------------------------------------------------
 * Base Model class.
 * Provides basic database operations.
 * Extend this class for your specific models.
 * --------------------------------------------------------
 */
class Model
{
    /**
     * @var Database
     */
    protected Database $db;

    /**
     * @var string Table name
     */
    protected string $table = '';

    /**
     * Model constructor.
     * Initializes the database connection.
     */
    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Get all records from the table
     *
     * @return array
     */
    public function all(): array
    {
        return $this->db->fetchAll("SELECT * FROM {$this->table}");
    }

    /**
     * Find a record by ID
     *
     * @param int $id
     * @return array|null
     */
    public function find(int $id): ?array
    {
        return $this->db->fetch("SELECT * FROM {$this->table} WHERE id = :id", ['id' => $id]);
    }

    /**
     * Insert a new record
     *
     * @param array $data
     * @return int Number of affected rows
     */
    public function create(array $data): int
    {
        $columns = implode(',', array_keys($data));
        $placeholders = ':' . implode(',:', array_keys($data));

        $sql = "INSERT INTO {$this->table} ({$columns}) VALUES ({$placeholders})";

        return $this->db->execute($sql, $data);
    }

    /**
     * Update a record by ID
     *
     * @param int $id
     * @param array $data
     * @return int Number of affected rows
     */
    public function update(int $id, array $data): int
    {
        $set = implode(',', array_map(fn($key) => "$key = :$key", array_keys($data)));
        $data['id'] = $id;

        $sql = "UPDATE {$this->table} SET {$set} WHERE id = :id";

        return $this->db->execute($sql, $data);
    }

    /**
     * Delete a record by ID
     *
     * @param int $id
     * @return int Number of affected rows
     */
    public function delete(int $id): int
    {
        $sql = "DELETE FROM {$this->table} WHERE id = :id";
        return $this->db->execute($sql, ['id' => $id]);
    }
}
