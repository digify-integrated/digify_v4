<section class="container">
    <h2><?= e($title) ?></h2>

    <?php if (!empty($error)): ?>
        <div style="color:red"><?= e($error) ?></div>
    <?php endif; ?>

    <form method="POST" action="/login">
        <?= csrf_field() ?>
        <label>Username:</label>
        <input type="text" name="username" required>
        <br>
        <label>Password:</label>
        <input type="password" name="password" required>
        <br>
        <button type="submit">Login</button>
    </form>
</section>
