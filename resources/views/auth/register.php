<?php 

use App\Core\Csrf;
use App\Core\Helpers;

?>

<form class="form w-100" id="login_form" method="post" action="#">
    <?= Csrf::field(); ?>
    <img src="./assets/images/logos/logo-dark.svg" class="mb-5 system-logo" alt="Logo-Dark" />
    <h2 class="mb-2 mt-4 fs-1 fw-bolder">Create an Account</h2>
    <p class="mb-10 fs-5">Enter your email below to login to your account</p>
    <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="text" class="form-control" id="email" name="email" autocomplete="off">
    </div>
    <div class="mb-3">
        <label for="password" class="form-label">Password</label>
        <div class="position-relative mb-3">
            <input class="form-control" type="password" id="password" name="password" autocomplete="off" />
            <span class="btn btn-sm btn-icon position-absolute translate-middle top-50 end-0 me-n2 password-addon">
                <i class="ki-outline ki-eye-slash fs-2 p-0"></i>
            </span>
        </div>
    </div>
    <div class="d-flex flex-stack flex-wrap gap-3 fs-base fw-semibold mb-8">
        <a href="<?= Helpers::baseUrl('/account-security/forgot') ?>" class="link-primary">Forgot Password?</a>
    </div>

    <div class="d-grid mb-10">
        <button id="signin" type="submit" class="btn btn-primary">Sign In</button>
    </div>
    <div class="text-gray-500 text-center fw-semibold fs-6">
        Not a Member yet?

        <a href="<?= Helpers::baseUrl('/register') ?>" class="link-primary">
            Sign up
        </a>
    </div>
</form>