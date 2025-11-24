<?php

namespace App\Models;

use App\Core\Model;

class UserModel extends Model
{
    public function findById($id)
    {
        $sql = 'CALL saveAddressType(
            :id
        )';

        $row = $this->fetch($sql, [
            'id' => $id
        ]);

        return $row['new_address_type_id'] ?? null;
    }
}
