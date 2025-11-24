import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#file-extension-table',
        ajaxUrl: './app/Controllers/FileExtensionController.php',
        transaction: 'generate file extension table',
        ajaxData: {
            filter_by_file_type: $('#filter_by_file_type').val(),
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'FILE_EXTENSION_NAME' },
            { data: 'FILE_TYPE_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 },
            { width: 'auto', targets: 2, responsivePriority: 3 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });

    generateDropdownOptions({
        url: './app/Controllers/FileTypeController.php',
        dropdownSelector: '#filter_by_file_type',
        data: { 
            transaction: 'generate file type options',
            multiple : true
        }
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#file-extension-table');
    initializeExportFeature('file_extension');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_file_type').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-file-extension')){
            const transaction           = 'delete multiple file extension';
            const file_extension_id     = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                                .filter(checkbox => checkbox.checked)
                                                .map(checkbox => checkbox.value);

            if (file_extension_id.length === 0) {
                showNotification('Deletion Multiple File Extensions Error', 'Please select the file extensions you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple File Extensions Deletion',
                text: 'Are you sure you want to delete these file extensions?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger',
                    cancelButton: 'btn btn-secondary'
                },
                buttonsStyling: false
            });

            if (!result.value) return;

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                file_extension_id.forEach(id => formData.append('file_extension_id[]', id));

                const response = await fetch('./app/Controllers/FileExtensionController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#file-extension-table');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete file extensions: ${error.message}`);
            }
        }
    });
});