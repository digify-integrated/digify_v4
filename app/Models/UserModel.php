<?php

declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

/**
 * Class UserModel
 * --------------------------------------------------------
 * Handles user-related database operations.
 * --------------------------------------------------------
 */
class UserModel extends Model
{
    /**
     * Get new address type ID for a user
     *
     * @param int $id User ID
     * @return int|null
     */
    public function getNewAddressTypeId(int $id): ?int
    {
        $row = $this->spRow('saveAddressType', ['id' => $id]);
        return isset($row['new_address_type_id']) ? (int)$row['new_address_type_id'] : null;
    }

    /**
     * Get all users
     *
     * @return array
     */
    public function getAllUsers(): array
    {
        return $this->sp('getAllUsers');
    }

    /**
     * Get a single user by ID
     *
     * @param int $id
     * @return array|null
     */
    public function getUserById(int $id): ?array
    {
        return $this->spRow('getUserById', ['id' => $id]);
    }

    /**
     * Get total count of users
     *
     * @return int
     */
    public function countUsers(): int
    {
        return (int)$this->spValue('countUsers');
    }
}
