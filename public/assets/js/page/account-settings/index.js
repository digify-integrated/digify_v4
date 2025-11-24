import { disableButton, enableButton, resetForm } from '../../utilities/form-utilities.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const displayDetails = async () => {
        const transaction = 'fetch account settings details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);

            const response = await fetch('./app/Controllers/UserAccountController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();
 
            if (data.success) { 
                $('#full_name_side_summary').text(data.fileAs || '--');
                $('#email_side_summary').text(data.email || '--');
                $('#phone_side_summary').text(data.phoneSummary || '--');
                $('#last_password_date_side_summary').text(data.lastPasswordChange || '--');
                $('#last_connection_date_side_summary').text(data.lastConnectionDate || '--');
                $('#last_password_reset_request_side_summary').text(data.lastPasswordResetRequest || '--');
                $('#last_failed_connection_date_side_summary').text(data.lastFailedConnectionDate || '--');
                $('#full_name_summary').text(data.fileAs || '--');
                $('#email_summary').text(data.email || '--');
                $('#phone_summary').text(data.phoneSummary || '--');

                document.getElementById('profile_picture_image').style.backgroundImage  = `url(${data.profilePicture})`;
                document.getElementById('status_side_summary').innerHTML                = data.activeBadge;
            } 
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location = data.redirect_link;
            } 
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch account settings details: ${error.message}`);
        }
    }

    const toggleSection = (section) => {
        $(`#${section}_button`).toggleClass('d-none');
        $(`#${section}`).toggleClass('d-none');
        $(`#${section}_edit`).toggleClass('d-none');

        const formName = section.replace(/^change_/, '');
        resetForm(`update_${formName}_form`);
    }
    
    displayDetails();

    $('#update_full_name_form').validate({
        rules: {
            full_name: { required: true }
        },
        messages: {
            full_name: { required: 'Enter the full name' }
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

            const transaction = 'update account settings full name';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

            disableButton('update_full_name_submit');

            try {
                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_full_name');
                    enableButton('update_full_name_submit');
                    displayDetails();
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_full_name_submit');
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
                enableButton('update_full_name_submit');
            }

            return false;
        }
    });

    $('#update_email_form').validate({
        rules: {
            email: { required: true }
        },
        messages: {
            email: { required: 'Enter the email' }
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

            const transaction = 'update account settings email';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

            disableButton('update_email_submit');

            try {
                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_email');
                    enableButton('update_email_submit');
                    displayDetails();
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_email_submit');
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
                enableButton('update_email_submit');
            }

            return false;
        }
    });

    $('#update_phone_form').validate({
        rules: {
            phone: { required: true }
        },
        messages: {
            phone: { required: 'Enter the phone' }
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

            const transaction = 'update account settings phone';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

            disableButton('update_phone_submit');

            try {
                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_phone');
                    enableButton('update_phone_submit');
                    displayDetails();
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_phone_submit');
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
                enableButton('update_phone_submit');
            }

            return false;
        }
    });

    $('#update_password_form').validate({
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
            new_password: { required: 'Enter the new password' },
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

            const transaction = 'update account settings password';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

            disableButton('update_password_submit');

            try {
                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_password');
                    enableButton('update_password_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_password_submit');
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
                enableButton('update_password_submit');
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('[data-toggle-section]')){
            const section = event.target.closest('[data-toggle-section]');
            const toggle_section  = section.dataset.toggleSection;
            toggleSection(toggle_section);
        }
    });

    document.addEventListener('change', async (event) => {
        const input = event.target.closest('#profile_picture');
        if (!input || !input.files.length) return;

        const transaction = 'update account settings profile picture';

        const formData = new FormData();
        formData.append('transaction', transaction);
        formData.append('profile_picture', input.files[0]);

        try {
            const response = await fetch('./app/Controllers/UserAccountController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
            }
            else if (data.invalid_session) {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = data.redirect_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    });
});