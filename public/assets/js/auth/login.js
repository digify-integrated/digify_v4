import { disableButton, enableButton } from '../utilities/form-utilities.js';
import { handleSystemError } from '../modules/system-errors.js';
import { showNotification } from '../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    $('#login_form').validate({
        rules: {
            email: { required: true },
            password: { required: true }
        },
        messages: {
            email: { required: 'Enter the email' },
            password: { required: 'Enter the password' }
        },
        errorPlacement: (error, element) => {
            showNotification('Action Needed: Issue Detected', error.text(), 'error', 2500);
        },
        highlight: (element) => {
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.addClass('is-invalid');
        },
        unhighlight: (element) => {
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.removeClass('is-invalid');
        },
        submitHandler: async (form, event) => {
            event.preventDefault();

            const transaction = 'authenticate';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

            disableButton('signin');

            try {
                const response = await fetch('./app/Controllers/AuthenticationController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Authentication failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    window.location.href = data.redirect_link;
                } else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('signin');
                }
            } catch (error) {
                enableButton('signin');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });
});
