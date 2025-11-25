<?php 

use App\Core\Csrf;
use App\Core\Helpers;

?>

<form class="form w-100" id="forgot_password_form" method="post" action="#">
    <?= Csrf::field(); ?>
    <img src="/assets/images/logos/logo-dark.svg" class="mb-5 system-logo" alt="Logo-Dark" />
    <h2 class="mb-2 mt-4 fs-1 fw-bolder">Forgot Password?</h2>
    <p class="mb-10 fs-5">Please enter the email address associated with your account. We will send you a link to reset your password.</p>
    <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="text" class="form-control" id="email" name="email" autocomplete="off">
    </div>

    <div class="d-flex flex-wrap justify-content-center pb-lg-0">
        <button id="forgot-password" type="submit" class="btn btn-primary me-4">Submit</button>
        <a href="<?= Helpers::baseUrl('/') ?>" class="btn btn-light">Cancel</a>            
    </div>
</form>