<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Model
 * --------------------------------------------------------
 * Base model providing stored procedure helpers.
 * --------------------------------------------------------
 */
abstract class Model
{
    protected Database $db;

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

    /**
     * Call a stored procedure and return multiple rows
     */
    protected function sp(string $procedure, array $params = []): array
    {
        return $this->db->callProcedure($procedure, $params);
    }

    /**
     * Call a stored procedure and return a single row
     */
    protected function spRow(string $procedure, array $params = []): ?array
    {
        return $this->db->callProcedureRow($procedure, $params);
    }

    /**
     * Call a stored procedure and return a single scalar value
     */
    protected function spValue(string $procedure, array $params = []): mixed
    {
        return $this->db->callProcedureValue($procedure, $params);
    }
}
