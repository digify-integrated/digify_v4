import { disableButton, enableButton, resetForm, initializeTinyMCE } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link                 = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const notification_setting_id   = document.getElementById('details-id')?.textContent.trim();

    const displayDetails = async () => {
        const transaction = 'fetch notification setting details';

        try {
            resetForm('notification_setting_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);

            const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('notification_setting_name').value          = data.notificationSettingName || '';
                document.getElementById('notification_setting_description').value   = data.notificationSettingDescription || '';
                
               ['system', 'email', 'sms'].forEach(t => $(`#${t}-notification`).prop('checked', data[`${t}Notification`] === 1));
            }
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = page_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    };

    const displaySystemTemplateDetails = async () => {
        const transaction = 'fetch system notification template details';

        try {
            resetForm('update_system_notification_template_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);

            const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('system_notification_title').value      = data.systemNotificationTitle || '';
                document.getElementById('system_notification_message').value    = data.systemNotificationMessage || '';
            }
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = page_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    };

    const displayEmailTemplateDetails = async () => {
        const transaction = 'fetch email notification template details';

        try {
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);

            const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('email_notification_subject').value = data.emailNotificationSubject || '';                
                tinymce.get('email_notification_body')?.setContent(data?.emailNotificationBody || '');
            }
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = page_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    };

    const displaySMSTemplateDetails = async () => {
        const transaction = 'fetch sms notification template details';

        try {
            resetForm('update_sms_notification_template_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);

            const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('sms_notification_message').value = data.smsNotificationMessage || '';
            }
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = page_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    };

    (async () => {
        await displayDetails();
        await displaySystemTemplateDetails();
        await displayEmailTemplateDetails();
        await displaySMSTemplateDetails();
    })();

    initializeTinyMCE('#email_notification_body', $('#email_notification_body').is(':disabled') ? 1 : undefined);
    attachLogNotesHandler('#log-notes-main', '#details-id', 'notification_setting');

    $('#notification_setting_form').validate({
        rules: {
            notification_setting_name: { required: true },
            notification_setting_description: { required: true }
        },
        messages: {
            notification_setting_name: { required: 'Enter the display name' },
            notification_setting_description: { required: 'Enter the description' }
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

            const transaction = 'save notification setting';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save notification setting failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                }
                else if(data.invalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                }
            } catch (error) {
                enableButton('submit-data');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_system_notification_template_form').validate({
        rules: {
            system_notification_title: { required: true },
            system_notification_message: { required: true }
        },
        messages: {
            system_notification_title: { required: 'Enter the title' },
            system_notification_message: { required: 'Enter the message' }
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

            const transaction = 'save system notification template';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);

            disableButton('submit-system-notification-template');

            try {
                const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save system notification template failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-system-notification-template');
                }
                else if(data.invalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-system-notification-template');
                }
            } catch (error) {
                enableButton('submit-system-notification-template');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_email_notification_template_form').validate({
        rules: {
            email_notification_subject: { required: true }
        },
        messages: {
            email_notification_subject: { required: 'Enter the subject' }
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

            const transaction               = 'save email notification template';
            const email_notification_body   = tinymce.get('email_notification_body').getContent();

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);
            formData.append('email_notification_body', email_notification_body);

            disableButton('submit-email-notification-template');

            try {
                const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save email notification template failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-email-notification-template');
                }
                else if(data.invalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-email-notification-template');
                }
            } catch (error) {
                enableButton('submit-email-notification-template');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_sms_notification_template_form').validate({
        rules: {
            sms_notification_message: { required: true }
        },
        messages: {
            sms_notification_message: { required: 'Enter the message' }
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

            const transaction = 'save sms notification template';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('notification_setting_id', notification_setting_id);

            disableButton('submit-sms-notification-template');

            try {
                const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save sms notification template failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-sms-notification-template');
                }
                else if(data.invalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-sms-notification-template');
                }
            } catch (error) {
                enableButton('submit-sms-notification-template');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#delete-notification-setting')){
            const transaction = 'delete notification setting';

            const result = await Swal.fire({
                title: 'Confirm Notification Setting Deletion',
                text: 'Are you sure you want to delete this notification setting?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            });

            if (result.isConfirmed) {
                try {
                    const formData = new URLSearchParams();
                    formData.append('transaction', transaction);
                    formData.append('notification_setting_id', notification_setting_id);

                    const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.href = page_link;
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
            }
        }

        if (event.target.closest('.update-notification-channel-status')){
            const transaction   = 'update notification setting channel';
            const button        = event.target.closest('.update-notification-channel-status');
            const channel       = button.dataset.channel;
            const status        = button.checked ? '1' : '0';

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('notification_setting_id', notification_setting_id);
                formData.append('channel', channel);
                formData.append('status', status);

                const response = await fetch('./app/Controllers/NotificationSettingController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

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
                handleSystemError(error, 'fetch_failed', `Failed to update notification channel: ${error.message}`);
            }
        }
    });
});