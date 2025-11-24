import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    initializeDatatable({
        selector: '#scrap-reason-table',
        ajaxUrl: './app/Controllers/ScrapReasonController.php',
        transaction: 'generate scrap reason table',
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'SCRAP_REASON_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });
    
    initializeDatatableControls('#scrap-reason-table');
    initializeExportFeature('scrap_reason');

    document.addEventListener('click', async (event) => {
        if (!event.target.closest('#delete-scrap-reason')) return;

        const transaction       = 'delete multiple scrap reason';
        const scrap_reason_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                    .filter(el => el.checked)
                                    .map(el => el.value);

        if (scrap_reason_id.length === 0) {
            showNotification('Deletion Multiple Scrap Reasons Error', 'Please select the scrap reasons you wish to delete.', 'error');
            return;
        }

        const result = await Swal.fire({
            title: 'Confirm Multiple Scrap Reasons Deletion',
            text: 'Are you sure you want to delete these scrap reasons?',
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
            scrap_reason_id.forEach(id => formData.append('scrap_reason_id[]', id));

            const response = await fetch('./app/Controllers/ScrapReasonController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Deletion failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
                reloadDatatable('#scrap-reason-table');
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