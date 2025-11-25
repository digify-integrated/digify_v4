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
