<?php

namespace App\Core;

/**
 * Class Controller
 * --------------------------------------------------------
 * Base Controller that all controllers extend.
 * Common controller functions (render, json, redirect)
 * can be added here later.
 * --------------------------------------------------------
 */
class Controller
{
    /**
     * Render a view file
     * (View system will be implemented later)
     *
     * @param string $view
     * @param array $data
     * @return void
     */
    protected function view(string $view, array $data = []): void
    {
        extract($data);

        $viewPath = dirname(__DIR__, 2) . "/resources/views/{$view}.php";

        if (!file_exists($viewPath)) {
            throw new \Exception("View '{$view}' not found.");
        }

        require $viewPath;
    }

    /**
     * Return JSON response
     *
     * @param array $data
     * @return void
     */
    protected function json(array $data): void
    {
        header('Content-Type: application/json');
        echo json_encode($data);
    }

    /**
     * Redirect to another URL
     *
     * @param string $url
     * @return void
     */
    protected function redirect(string $url): void
    {
        header("Location: $url");
        exit;
    }
}
