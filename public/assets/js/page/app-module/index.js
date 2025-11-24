import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    initializeDatatable({
        selector: '#app-module-table',
        ajaxUrl: './app/Controllers/AppModuleController.php',
        transaction: 'generate app module table',
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'APP_MODULE_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });
    
    initializeDatatableControls('#app-module-table');
    initializeExportFeature('app_module');

    document.addEventListener('click', async (event) => {
        if (!event.target.closest('#delete-app-module')) return;

        const transaction       = 'delete multiple app module';
        const app_module_id     = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                    .filter(el => el.checked)
                                    .map(el => el.value);

        if (app_module_id.length === 0) {
            showNotification('Deletion Multiple App Module Error', 'Please select the app modules you wish to delete.', 'error');
            return;
        }

        const result = await Swal.fire({
            title: 'Confirm Multiple App Modules Deletion',
            text: 'Are you sure you want to delete these app modules?',
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

        if (!result.isConfirmed) return;

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            app_module_id.forEach(id => formData.append('app_module_id[]', id));

            const response = await fetch('./app/Controllers/AppModuleController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Deletion failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
                reloadDatatable('#app-module-table');
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