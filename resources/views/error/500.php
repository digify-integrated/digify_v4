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

<body  id="kt_body" class="app-blank bgi-size-cover bgi-position-center bgi-no-repeat" >
    <div class="d-flex flex-column flex-root" id="kt_app_root">
        <style>
            body {
                background-image: url('./assets/images/auth/bg7.jpg');
            }

            [data-bs-theme="dark"] body {
                background-image: url('./assets/images/auth/bg7-dark.jpg');
            }
        </style>

        <div class="d-flex flex-column flex-center flex-column-fluid">    
            <div class="d-flex flex-column flex-center text-center p-10">       
                <div class="card card-flush w-lg-650px py-5">
                    <div class="card-body py-15 py-lg-20">
                        <h1 class="fw-bolder fs-2hx text-gray-900 mb-4">
                            System Error
                        </h1>
                        <div class="fw-semibold fs-6 text-gray-500 mb-7">
                            Something went wrong! Please try again later.
                        </div>
                        <div class="mb-3">
                            <img src="assets/images/auth/500-error.png" class="mw-100 mh-300px theme-light-show" alt=""/>
                            <img src="assets/images/auth/500-error-dark.png" class="mw-100 mh-300px theme-dark-show" alt=""/>
                        </div>
                        <div class="mb-0">
                            <a href="<?= Helpers::baseUrl('/') ?>" class="btn btn-sm btn-primary">Return Home</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <?php require_once __DIR__ . '/../partials/required-js.php'; ?>
</body>
</html>