import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#unit-table',
        ajaxUrl: './app/Controllers/UnitController.php',
        transaction: 'generate unit table',
        ajaxData: {
            filter_by_unit_type: $('#filter_by_unit_type').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'UNIT_NAME' },
            { data: 'UNIT_ABBREVIATION' },
            { data: 'UNIT_TYPE_NAME' },
            { data: 'RATIO_TO_BASE' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 },
            { width: 'auto', targets: 2, responsivePriority: 3 },
            { width: 'auto', targets: 3, responsivePriority: 4 },
            { width: 'auto', targets: 4, responsivePriority: 5 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });
    
    generateDropdownOptions({
        url: './app/Controllers/UnitTypeController.php',
        dropdownSelector: '#filter_by_unit_type',
        data: { transaction: 'generate unit type options', multiple : true }
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#unit-table');
    initializeExportFeature('unit');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_unit_type').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-unit')){
            const transaction   = 'delete multiple unit';
            const unit_id  = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                    .filter(checkbox => checkbox.checked)
                                    .map(checkbox => checkbox.value);

            if (unit_id.length === 0) {
                showNotification('Deletion Multiple Units Error', 'Please select the units you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Units Deletion',
                text: 'Are you sure you want to delete these units?',
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
                unit_id.forEach(id => formData.append('unit_id[]', id));

                const response = await fetch('./app/Controllers/UnitController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#unit-table');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete units: ${error.message}`);
            }
        }
    });
});