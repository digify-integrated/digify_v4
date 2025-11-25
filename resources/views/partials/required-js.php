<?php use App\Core\Helpers; ?>

<!-- Core Vendor JS -->
<?= Helpers::js('vendor/global/plugins.bundle.js', true) ?>
<?= Helpers::js('assets/js/scripts.bundle.js', true) ?>

<!-- Plugin JS -->
<?= Helpers::js('vendor/bootstrap-duallistbox/dist/jquery.bootstrap-duallistbox.min.js', true) ?>
<?= Helpers::js('vendor/jquery-validation/dist/jquery.validate.min.js', true) ?>
<?= Helpers::js('vendor/jquery-validation/validation/form-validation-rules.js', true) ?>
<?= Helpers::js('assets/js/app.js', true, true) ?>