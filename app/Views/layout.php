<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title><?= e($title ?? ($appName ?? 'digify_v4')) ?></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body>
    <div id="app">
        <header>
            <h1><?= e($appName ?? 'digify_v4') ?></h1>
        </header>

        <main>
            <?= $content ?>
        </main>

        <footer>
            <p>&copy; <?= date('Y') ?> <?= e($appName ?? 'digify_v4') ?></p>
        </footer>
    </div>

    <script type="module" src="/assets/js/main.js"></script>
</body>
</html>
