<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>digify_v4 - Home</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f4f4; padding: 40px; }
        h1 { color: #333; }
        p { font-size: 1.1rem; }
    </style>
</head>
<body>
    <h1>Welcome to digify_v4!</h1>
    <p>Hello, <?= htmlspecialchars($name ?? 'Guest') ?>. Your lightweight PHP MVC is working!</p>
</body>
</html>
