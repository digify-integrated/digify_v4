import { disableButton, enableButton, resetForm } from '../../utilities/form-utilities.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    document.addEventListener('click', (event) => {
        if (!event.target.closest('#reset-import')) return;

        document.querySelectorAll('.upload-file-default-preview').forEach(el => el.classList.remove('d-none'));
        document.querySelectorAll('.upload-file-preview').forEach(el => el.classList.add('d-none'));

        resetForm('upload_form');
        document.getElementById('upload-file-preview-table').innerHTML = '';
    });

    $('#upload_form').validate({
        rules: {
            import_file: { required: true }
        },
        messages: {
            import_file: { required: 'Choose the import file' }
        },
        errorPlacement: (error) => {
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

            const transaction   = document.querySelector('.upload-file-preview').classList.contains('d-none')
                                    ? 'generate import data preview'
                                    : 'save import data';
            const page_link     = document.getElementById('page-link').getAttribute('href') || 'apps.php';

            const formData = new FormData(form);
            formData.append('transaction', transaction);

            try {
                disableButton(['submit-upload', 'import', 'reset-import']);

                const response = await fetch('./app/Controllers/ImportController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Request failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    const $preview          = $('.upload-file-preview');
                    const $defaultPreview   = $('.upload-file-default-preview');

                    if ($preview.hasClass('d-none')) {
                        $defaultPreview.addClass('d-none');
                        $preview.removeClass('d-none');

                        document.getElementById('upload-file-preview-table').innerHTML = data.preview;
                        
                        $('#upload-modal').modal('hide');
                        enableButton(['submit-upload', 'import', 'reset-import']);
                    }
                    else {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.href = page_link;
                    }
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton(['submit-upload', 'import', 'reset-import']);
                }
            } catch (error) {
                enableButton(['submit-upload', 'import', 'reset-import']);
                handleSystemError(error, 'fetch_failed', `Import request failed: ${error.message}`);
            }

            return false;
        }
    });
});
