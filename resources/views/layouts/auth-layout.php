<?php use App\Core\Helpers; ?>

<!DOCTYPE html>
<html lang="en">
<head>
    <?php 
        require_once __DIR__ . '/../partials/head-meta-tags.php';
        require_once __DIR__ . '/../partials/head-stylesheet.php';
    ?>
</head>

<?php require_once __DIR__ . '/../partials/theme-script.php'; ?>

<body id="kt_body" class="app-blank bgi-size-cover bgi-attachment-fixed bgi-position-center bgi-no-repeat" data-kt-app-page-loading-enabled="true" data-kt-app-page-loading="true">
    <div class="d-flex flex-column flex-lg-row flex-column-fluid">
        <div class="d-flex flex-column flex-lg-row-fluid w-lg-50 p-10 order-2 order-lg-1">
            <div class="d-flex flex-center flex-column flex-lg-row-fluid">
                <div class="w-lg-600px p-10">
                    <?= $content ?>
                </div>
            </div>
        </div>
        
        <div class="d-flex flex-lg-row-fluid w-lg-50 bgi-size-cover bgi-position-center order-1 order-lg-2" style="background-image: url('<?= Helpers::baseUrl('assets/images/background/login-bg.jpg') ?>');">
        </div>
    </div>

    <?php require_once __DIR__ . '/../partials/error-modal.php'; ?>
    <?php require_once __DIR__ . '/../partials/required-js.php'; ?>

    <?= Helpers::js('assets/js/auth/login.js', true, true) ?>
</body>
</html>
