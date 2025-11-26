<?php

declare(strict_types=1);

namespace App\Core;

/**
 * Class Controller
 * --------------------------------------------------------
 * Base controller providing helpers for:
 * - Request & Response access
 * - Views with optional layouts
 * - JSON responses
 * - Redirects
 * - Flash messages
 * --------------------------------------------------------
 */
abstract class Controller
{
    protected Request $request;
    protected Response $response;
    protected string $defaultLayout = 'main';

    /**
     * Controller constructor.
     * Automatically injects Request and Response.
     *
     * @param Request|null  $request
     * @param Response|null $response
     */
    public function __construct(?Request $request = null, ?Response $response = null)
    {
        $this->request  = $request ?? new Request();
        $this->response = $response ?? new Response();

        // Ensure session started for flash messages
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start([
                'cookie_httponly' => true,
                'cookie_samesite' => 'Lax',
            ]);
        }
    }

    // --------------------------------------------------------
    // View Rendering
    // --------------------------------------------------------

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

        $flash = $_SESSION['_flash'] ?? [];
        unset($_SESSION['_flash']);

        if ($layout === null) {
            require $viewPath;
            return;
        }

        $layoutPath = "{$basePath}/layouts/{$layout}.php";
        if (!file_exists($layoutPath)) {
            $this->response->setStatusCode(500)
                           ->text("Layout '{$layout}' not found at {$layoutPath}");
            return;
        }

        ob_start();
        require $viewPath;
        $content = ob_get_clean();

        require $layoutPath;
    }

    // --------------------------------------------------------
    // JSON Response
    // --------------------------------------------------------

    protected function json(array $data, int $statusCode = 200): void
    {
        $this->response->json($data, $statusCode);
    }

    // --------------------------------------------------------
    // Redirect with optional flash
    // --------------------------------------------------------

    protected function redirect(string $url, int $statusCode = 302, array $flash = []): void
    {
        if (!empty($flash)) {
            $_SESSION['_flash'] = $flash;
        }
        $this->response->redirect($url, $statusCode);
    }

    // --------------------------------------------------------
    // Flash Message Helpers
    // --------------------------------------------------------

    protected function flash(string $key, string $message): void
    {
        $_SESSION['_flash'][$key] = $message;
    }

    protected function getFlash(string $key, ?string $default = null): ?string
    {
        return $_SESSION['_flash'][$key] ?? $default;
    }
}
