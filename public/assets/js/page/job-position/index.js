import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    initializeDatatable({
        selector: '#job-position-table',
        ajaxUrl: './app/Controllers/JobPositionController.php',
        transaction: 'generate job position table',
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'JOB_POSITION_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });
    
    initializeDatatableControls('#job-position-table');
    initializeExportFeature('job_position');

    document.addEventListener('click', async (event) => {
        if (!event.target.closest('#delete-job-position')) return;

        const transaction       = 'delete multiple job position';
        const job_position_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                        .filter(el => el.checked)
                                        .map(el => el.value);

        if (job_position_id.length === 0) {
            showNotification('Deletion Multiple Job Positions Error', 'Please select the job positions you wish to delete.', 'error');
            return;
        }

        const result = await Swal.fire({
            title: 'Confirm Multiple Job Positions Deletion',
            text: 'Are you sure you want to delete these job positions?',
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
            job_position_id.forEach(id => formData.append('job_position_id[]', id));

            const response = await fetch('./app/Controllers/JobPositionController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Deletion failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
                reloadDatatable('#job-position-table');
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