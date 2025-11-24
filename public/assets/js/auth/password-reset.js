import { disableButton, enableButton } from '../utilities/form-utilities.js';
import { handleSystemError } from '../modules/system-errors.js';
import { showNotification, setNotification } from '../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    $('#password_reset_form').validate({
        rules: {
            new_password: {
                required: true,
                password_strength: true
            },
            confirm_password: {
                required: true,
                equalTo: '#new_password'
            }
        },
        messages: {
            new_password: {
                required: 'Enter the password'
            },
            confirm_password: {
                required: 'Enter the confirm password',
                equalTo: 'The passwords you entered do not match'
            }
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

            const transaction = 'password reset';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

            disableButton('reset');

            try {
                const response = await fetch('./app/Controllers/AuthenticationController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Password reset failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (response.success) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                } else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('reset');
                }
            } catch (error) {
                enableButton('reset');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });
});
