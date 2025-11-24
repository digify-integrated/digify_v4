<?php

namespace App\Core;

class Controller
{
    /**
     * Render a view with optional layout support
     *
     * Usage:
     *   return $this->view('auth/login', [], 'auth-layout');
     *   return $this->view('dashboard/index'); // no layout
     *
     * @param string $view   View file path (relative to resources/views/)
     * @param array  $data   Data to be extracted into the view
     * @param string|null $layout  Layout file name (inside resources/views/layouts/)
     *
     * @return void
     */
    protected function view(string $view, array $data = [], ?string $layout = null): void
    {
        extract($data);

        $basePath = dirname(__DIR__, 2) . "/resources/views";

        $viewPath = $basePath . "/{$view}.php";

        if (!file_exists($viewPath)) {
            throw new \Exception("View '{$view}' not found at {$viewPath}");
        }

        // If no layout → load view directly
        if ($layout === null) {
            require $viewPath;
            return;
        }

        // Layout mode: capture view output
        ob_start();
        require $viewPath;
        $content = ob_get_clean();

        // Load layout file
        $layoutPath = $basePath . "/layouts/{$layout}.php";

        if (!file_exists($layoutPath)) {
            throw new \Exception("Layout '{$layout}' not found at {$layoutPath}");
        }

        require $layoutPath;
    }

    /**
     * Return JSON response
     */
    protected function json(array $data): void
    {
        header('Content-Type: application/json');
        echo json_encode($data);
    }

    /**
     * Redirect to another URL
     */
    protected function redirect(string $url): void
    {
        header("Location: $url");
        exit;
    }
}
