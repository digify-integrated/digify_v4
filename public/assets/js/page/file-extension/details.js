import { disableButton, enableButton, generateDropdownOptions, resetForm } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link             = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const file_extension_id     = document.getElementById('details-id')?.textContent.trim();

    const displayDetails = async () => {
        const transaction = 'fetch file extension details';

        try {
            resetForm('file_extension_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('file_extension_id', file_extension_id);

            const response = await fetch('./app/Controllers/FileExtensionController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('file_extension_name').value    = data.fileExtensionName || '';
                document.getElementById('file_extension').value         = data.fileExtension || '';

                $('#file_type_id').val(data.fileTypeID).trigger('change');
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
        await generateDropdownOptions({
            url: './app/Controllers/FileTypeController.php',
            dropdownSelector: '#file_type_id',
            data: { transaction: 'generate file type options' }
        });

        await displayDetails();
    })();    

    attachLogNotesHandler('#log-notes-main', '#details-id', 'file_extension');

    $('#file_extension_form').validate({
        rules: {
            file_extension_name: { required: true },
            file_extension: { required: true },
            file_type_id: { required: true }
        },
        messages: {
            file_extension_name: { required: 'Enter the display name' },
            file_extension: { required: 'Enter the file extension' },
            file_type_id: { required: 'Select the file type' }
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

            const transaction = 'save file extension';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('file_extension_id', file_extension_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/FileExtensionController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save file extension failed with status: ${response.status}`);
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

    document.addEventListener('click', async (event) => {
        if (!event.target.closest('#delete-file-extension')) return;

        const transaction = 'delete file extension';

        const result = await Swal.fire({
            title: 'Confirm File Extension Deletion',
            text: 'Are you sure you want to delete this file extension?',
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
                formData.append('file_extension_id', file_extension_id);

                const response = await fetch('./app/Controllers/FileExtensionController.php', {
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
    });
});