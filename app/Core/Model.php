<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Model
 * --------------------------------------------------------
 * Base model providing database helpers.
 * Supports:
 * - Stored procedures
 * - Query helpers (fetch, fetchAll, insert, update, delete)
 * - Optional dependency injection for testing
 * - Optional soft delete & timestamps
 * --------------------------------------------------------
 */
abstract class Model
{
    protected Database $db;

    /**
     * Optional: table name for CRUD convenience
     */
    protected ?string $table = null;

    /**
     * Optional: soft delete column
     */
    protected ?string $softDeleteColumn = null;

    /**
     * Optional: timestamp columns
     */
    protected ?string $createdAtColumn = 'created_at';
    protected ?string $updatedAtColumn = 'updated_at';

    /**
     * Model constructor
     *
     * @param Database|null $database Optional Database instance for testing/flexibility
     */
    public function __construct(?Database $database = null)
    {
        $this->db = $database ?? Database::getInstance();
    }

    // --------------------------------------------------------
    // Stored Procedure Helpers
    // --------------------------------------------------------

    protected function sp(string $procedure, array $params = []): array
    {
        $placeholders = implode(',', array_fill(0, count($params), '?'));
        $sql = "CALL {$procedure}($placeholders)";
        return $this->db->query($sql, $params);
    }

    protected function spRow(string $procedure, array $params = []): ?array
    {
        $rows = $this->sp($procedure, $params);
        return $rows[0] ?? null;
    }

    protected function spValue(string $procedure, array $params = []): mixed
    {
        $row = $this->spRow($procedure, $params);
        return $row ? array_values($row)[0] : null;
    }

    // --------------------------------------------------------
    // Query Helpers
    // --------------------------------------------------------

    protected function fetch(string $sql, array $params = []): ?array
    {
        return $this->db->fetch($sql, $params);
    }

    protected function fetchAll(string $sql, array $params = []): array
    {
        return $this->db->query($sql, $params);
    }

    protected function insert(array $data): int|string
    {
        if (!$this->table) {
            throw new \RuntimeException('Table name not defined in model.');
        }

        // Handle timestamps
        if ($this->createdAtColumn) {
            $data[$this->createdAtColumn] = date('Y-m-d H:i:s');
        }
        if ($this->updatedAtColumn) {
            $data[$this->updatedAtColumn] = date('Y-m-d H:i:s');
        }

        return $this->db->insert($this->table, $data);
    }

    protected function update(array $data, string $where, array $whereParams = []): int
    {
        if (!$this->table) {
            throw new \RuntimeException('Table name not defined in model.');
        }

        // Handle updated_at
        if ($this->updatedAtColumn) {
            $data[$this->updatedAtColumn] = date('Y-m-d H:i:s');
        }

        return $this->db->update($this->table, $data, $where, $whereParams);
    }

    protected function delete(string $where, array $params = []): int
    {
        if (!$this->table) {
            throw new \RuntimeException('Table name not defined in model.');
        }

        if ($this->softDeleteColumn) {
            // Perform soft delete
            return $this->update([$this->softDeleteColumn => 1], $where, $params);
        }

        return $this->db->delete($this->table, $where, $params);
    }
}
