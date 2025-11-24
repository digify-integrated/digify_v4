import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    initializeDatatable({
        selector: '#civil-status-table',
        ajaxUrl: './app/Controllers/CivilStatusController.php',
        transaction: 'generate civil status table',
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'CIVIL_STATUS_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });
    
    initializeDatatableControls('#civil-status-table');
    initializeExportFeature('civil_status');

    document.addEventListener('click', async (event) => {
        if (!event.target.closest('#delete-civil-status')) return;

        const transaction       = 'delete multiple civil status';
        const civil_status_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                    .filter(el => el.checked)
                                    .map(el => el.value);

        if (civil_status_id.length === 0) {
            showNotification('Deletion Multiple Civil Status Error', 'Please select the civil status you wish to delete.', 'error');
            return;
        }

        const result = await Swal.fire({
            title: 'Confirm Multiple Civil Status Deletion',
            text: 'Are you sure you want to delete these civil status?',
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
            civil_status_id.forEach(id => formData.append('civil_status_id[]', id));

            const response = await fetch('./app/Controllers/CivilStatusController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Deletion failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
                reloadDatatable('#civil-status-table');
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