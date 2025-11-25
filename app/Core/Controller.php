<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Controller
 * --------------------------------------------------------
 * Base controller providing helpers for:
 * - Views
 * - JSON responses
 * - Redirects
 * --------------------------------------------------------
 */
class Controller
{
    protected Response $response;

    /**
     * Controller constructor
     */
    public function __construct(?Response $response = null)
    {
        $this->response = $response ?? new Response();
    }

    // --------------------------------------------------------
    // View Rendering
    // --------------------------------------------------------

    /**
     * Render a view with optional layout
     *
     * Usage:
     *   $this->view('auth/login', [], 'auth-layout');
     *   $this->view('dashboard/index'); // no layout
     */
    protected function view(string $view, array $data = [], ?string $layout = null): void
    {
        $basePath = dirname(__DIR__, 2) . '/resources/views';
        $viewPath = "{$basePath}/{$view}.php";

        if (!file_exists($viewPath)) {
            $this->response->setStatusCode(500)
                           ->text("View '{$view}' not found at {$viewPath}");
            return;
        }

        extract($data, EXTR_SKIP);

        if ($layout === null) {
            require $viewPath;
            return;
        }

        ob_start();
        require $viewPath;
        $content = ob_get_clean();

        $layoutPath = "{$basePath}/layouts/{$layout}.php";
        if (!file_exists($layoutPath)) {
            $this->response->setStatusCode(500)
                           ->text("Layout '{$layout}' not found at {$layoutPath}");
            return;
        }

        require $layoutPath;
    }

    // --------------------------------------------------------
    // JSON Response
    // --------------------------------------------------------

    protected function json(array $data, ?int $statusCode = null): void
    {
        $this->response->json($data, $statusCode ?? 200);
    }

    // --------------------------------------------------------
    // Redirect
    // --------------------------------------------------------

    protected function redirect(string $url, int $statusCode = 302): void
    {
        $this->response->redirect($url, $statusCode);
    }
}
