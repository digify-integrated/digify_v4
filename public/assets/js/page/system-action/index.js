import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    initializeDatatable({
        selector: '#system-action-table',
        ajaxUrl: './app/Controllers/SystemActionController.php',
        transaction: 'generate system action table',
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'SYSTEM_ACTION_NAME' }
        ],
        columnDefs: [
            { width: '1%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });

    initializeDatatableControls('#system-action-table');
    initializeExportFeature('system_action');

    document.addEventListener('click', async (e) => {
        if (!e.target.closest('#delete-system-action')) return;

        const transaction       = 'delete multiple system action';
        const system_action_id  = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                        .filter(checkbox => checkbox.checked)
                                        .map(checkbox => checkbox.value);

        if (system_action_id.length === 0) {
            showNotification('Deletion Multiple System Action Error', 'Please select the system actions you wish to delete.','error');
            return;
        }

        const result = await Swal.fire({
            title: 'Confirm Multiple System Actions Deletion',
            text: 'Are you sure you want to delete these system actions?',
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
            system_action_id.forEach(id => formData.append('system_action_id[]', id));

            const response = await fetch('./app/Controllers/SystemActionController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
                reloadDatatable('#system-action-table');
            }
            else if (data.invalid_session) {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = data.redirect_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to delete multiple system actions: ${error.message}`);
        }
    });
});