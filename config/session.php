<?php
return [
    'lifetime' => (int) ($_ENV['SESSION_LIFETIME'] ?? 604800)
];
