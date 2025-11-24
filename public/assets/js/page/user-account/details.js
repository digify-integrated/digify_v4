import { disableButton, enableButton, generateDualListBox, resetForm } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link         = document.getElementById('page-link').getAttribute('href') || 'apps.php';
    const user_account_id   = document.getElementById('details-id')?.textContent.trim() || '';

    const displayDetails = async () => {
        const transaction = 'fetch user account details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('user_account_id', user_account_id);

            const response = await fetch('./app/Controllers/UserAccountController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                $('#full_name_side_summary').text(data.fileAs || '--');
                $('#email_side_summary').text(data.email || '--');
                $('#last_password_date_side_summary').text(data.lastPasswordChange || '--');
                $('#last_connection_date_side_summary').text(data.lastConnectionDate || '--');
                $('#last_password_reset_request_side_summary').text(data.lastPasswordResetRequest || '--');
                $('#last_failed_connection_date_side_summary').text(data.lastFailedConnectionDate || '--');
                $('#full_name_summary').text(data.fileAs || '--');
                $('#email_summary').text(data.email || '--');
                $('#phone_summary').text(data.phoneSummary || '--');

                document.getElementById('two-factor-authentication').checked            = data.twoFactorAuthentication === 'Yes';
                document.getElementById('multiple-login-sessions').checked              = data.multipleSession === 'Yes';
                document.getElementById('profile_picture_image').style.backgroundImage  = `url(${data.profilePicture})`;
                document.getElementById('status_side_summary').innerHTML                = data.activeBadge;
            } 
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location = page_link;
            } 
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch user account details: ${error.message}`);
        }
    }

    const roleList = async () => {
        const transaction = 'generate assigned user account role list';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('user_account_id', user_account_id);

            const response = await fetch('./app/Controllers/UserAccountController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();
            
            document.getElementById('role-list').innerHTML = data[0].ROLE_USER_ACCOUNT;

        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch role list: ${error.message}`);
        }
    }

    const toggleSection = (section) => {
        $(`#${section}_button`).toggleClass('d-none');
        $(`#${section}`).toggleClass('d-none');
        $(`#${section}_edit`).toggleClass('d-none');

        const formName = section.replace(/^change_/, '');
        resetForm(`update_${formName}_form`);
    }

    attachLogNotesHandler('#log-notes-main', '#details-id', 'user_account');
    roleList();
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

            const transaction = 'update user account full name';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('user_account_id', user_account_id);

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

            const transaction = 'update user account email';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('user_account_id', user_account_id);

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

            const transaction = 'update user account phone';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('user_account_id', user_account_id);

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
            }
        },
        messages: {
            new_password: { required: 'Enter the new password' }
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

            const transaction = 'update user account password';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('user_account_id', encodeURIComponent(user_account_id));

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

    $('#role_assignment_form').validate({
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

            const transaction = 'save user account role';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('user_account_id', encodeURIComponent(user_account_id));

            disableButton('submit-assignment');

            try {
                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    $('#role-assignment-modal').modal('hide');
                    enableButton('submit-assignment');
                    roleList();
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-assignment');
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
                enableButton('submit-assignment');
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#activate-user-account')){
            const transaction = 'activate user account';

            Swal.fire({
                title: 'Confirm User Account Activation',
                text: 'Are you sure you want to activate this user account?',
                icon: 'info',
                showCancelButton: true,
                confirmButtonText: 'Activate',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-success mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            }).then(async (result) => {
                if (!result.value) return;

                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('user_account_id', user_account_id);

                try {
                    const response = await fetch('./app/Controllers/UserAccountController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.reload();
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
        }

        if (event.target.closest('#deactivate-user-account')){
            const transaction = 'deactivate user account';

            Swal.fire({
                title: 'Confirm User Account Deactivation',
                text: 'Are you sure you want to deactivate this user account?',
                icon: 'info',
                showCancelButton: true,
                confirmButtonText: 'Deactivate',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            }).then(async (result) => {
                if (!result.value) return;

                const formData = new URLSearchParams();
                formData.append('user_account_id', user_account_id);
                formData.append('transaction', transaction);

                try {
                    const response = await fetch('./app/Controllers/UserAccountController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.reload();
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
        }

        if (event.target.closest('#delete-user-account')){
            const transaction = 'delete user account';

            Swal.fire({
                title: 'Confirm User Account Deletion',
                text: 'Are you sure you want to delete this user account?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            }).then(async (result) => {
                if (!result.value) return;

                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('user_account_id', user_account_id);
                
                try {
                    const response = await fetch('./app/Controllers/UserAccountController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location = page_link;
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
        }

        if (event.target.closest('#two-factor-authentication')){
            const transaction = 'update user account two factor authentication';

            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('user_account_id', user_account_id);

            try {
                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                const data = await response.json();

                if (!data.success) {
                    if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                        window.location.href = data.redirect_link;
                    }
                    else {
                        showNotification(data.title, data.message, data.message_type);
                    }
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }
        }

        if (event.target.closest('#multiple-login-sessions')){
            const transaction = 'update user account multiple login sessions';

            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('user_account_id', user_account_id);

            try {
                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                const data = await response.json();

                if (!data.success) {
                    if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                        window.location.href = data.redirect_link;
                    }
                    else {
                        showNotification(data.title, data.message, data.message_type);
                    }
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }
        }

        if (event.target.closest('#assign-role')){
            generateDualListBox({
                url: './app/Controllers/UserAccountController.php',
                selectSelector: 'role_id',
                data: {
                    transaction: 'generate user account role dual listbox options',
                    user_account_id: user_account_id
                }
            });
        }

        if (event.target.closest('[data-toggle-section]')){
            const section = event.target.closest('[data-toggle-section]');
            const toggle_section  = section.dataset.toggleSection;
            toggleSection(toggle_section);
        }

        if (event.target.closest('.delete-role-user-account')){
            const transaction           = 'delete user account role';
            const button                = event.target.closest('.delete-role-user-account');
            const role_user_account_id  = button.dataset.roleUserAccountId;

            Swal.fire({
                title: 'Confirm Role Deletion',
                text: 'Are you sure you want to delete this role?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            }).then(async (result) => {
                if (!result.value) return;

                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('role_user_account_id', role_user_account_id);

                try {
                    const response = await fetch('./app/Controllers/UserAccountController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        roleList();
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
        }
    });

    document.addEventListener('change', async (event) => {
        const input = event.target.closest('#profile_picture');
        if (!input || !input.files.length) return;

        const transaction = 'update user account profile picture';

        const formData = new FormData();
        formData.append('transaction', transaction);
        formData.append('user_account_id', user_account_id);
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
                displayDetails();
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