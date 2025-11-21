<section class="container">
    <h2><?= e($title) ?></h2>
    <p>This is the starter home page for <strong><?= e($appName) ?></strong>.</p>

    <p>Routes defined in <code>routes/web.php</code>. Public assets in <code>public/assets/</code>.</p>
    <section class="container">
    <h2><?= e($title) ?></h2>

    <form method="POST" action="/submit">
        <?= csrf_field() ?>
        <label for="name">Name:</label>
        <input type="text" name="name" required>
        <button type="submit">Submit</button>
    </form>

</section>

</section>
