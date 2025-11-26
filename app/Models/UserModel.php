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
final class UserModel extends Model
{
    protected ?string $table = 'users';

    // Optional: enable soft delete (requires `deleted_at` column)
    protected ?string $softDeleteColumn = 'deleted_at';

    // --------------------------------------------------------
    // Retrieve user by ID
    // --------------------------------------------------------
    public function findById(int $id): ?array
    {
        $sql = "SELECT * FROM {$this->table} WHERE id = :id";
        if ($this->softDeleteColumn) {
            $sql .= " AND {$this->softDeleteColumn} IS NULL";
        }
        $sql .= " LIMIT 1";

        return $this->fetch($sql, ['id' => $id]);
    }

    // --------------------------------------------------------
    // Retrieve user by email
    // --------------------------------------------------------
    public function findByEmail(string $email): ?array
    {
        $sql = "SELECT * FROM {$this->table} WHERE email = :email";
        if ($this->softDeleteColumn) {
            $sql .= " AND {$this->softDeleteColumn} IS NULL";
        }
        $sql .= " LIMIT 1";

        return $this->fetch($sql, ['email' => $email]);
    }

    // --------------------------------------------------------
    // Create new user
    // --------------------------------------------------------
    public function create(array $data): int
    {
        // Expect $data['password'] to be already hashed
        return $this->insert([
            'name'     => $data['name'],
            'email'    => $data['email'],
            'password' => $data['password'],
        ]);
    }

    // --------------------------------------------------------
    // Update user
    // --------------------------------------------------------
    public function updateUser(int $id, array $data): int
    {
        $updateData = [];

        foreach (['name', 'email', 'password'] as $field) {
            if (isset($data[$field])) {
                $updateData[$field] = $data[$field];
            }
        }

        if (empty($updateData)) {
            return 0;
        }

        return $this->update($updateData, 'id = :id', ['id' => $id]);
    }

    // --------------------------------------------------------
    // Delete user
    // --------------------------------------------------------
    public function deleteUser(int $id): int
    {
        if ($this->softDeleteColumn) {
            return $this->update([$this->softDeleteColumn => date('Y-m-d H:i:s')], 'id = :id', ['id' => $id]);
        }

        return $this->delete('id = :id', ['id' => $id]);
    }

    // --------------------------------------------------------
    // Authenticate user
    // --------------------------------------------------------
    public function authenticate(string $email, string $password): ?array
    {
        $user = $this->findByEmail($email);

        if ($user && password_verify($password, $user['password'])) {
            return $user;
        }

        return null;
    }
}
