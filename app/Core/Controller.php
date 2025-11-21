<?php
declare(strict_types=1);

namespace App\Core;

abstract class Controller
{
    protected function view(string $view, array $data = []): void
    {
        $viewPath = __DIR__ . "/../Views/{$view}.php";
        if (!file_exists($viewPath)) {
            throw new \RuntimeException("View {$view} not found at {$viewPath}");
        }
        // make data variables available in view
        extract($data, EXTR_SKIP);
        // buffer and render into layout
        ob_start();
        require $viewPath;
        $content = ob_get_clean();
        // layout
        require __DIR__ . '/../Views/layout.php';
    }

    protected function json($data): void
    {
        header('Content-Type: application/json');
        echo json_encode($data);
    }
}
