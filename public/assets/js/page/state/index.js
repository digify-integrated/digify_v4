import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';


document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#state-table',
        ajaxUrl: './app/Controllers/StateController.php',
        transaction: 'generate state table',
        ajaxData: {
            filter_by_country: $('#filter_by_country').val(),
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'STATE_NAME' },
            { data: 'COUNTRY_NAME' }
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
        url: './app/Controllers/CountryController.php',
        dropdownSelector: '#filter_by_country',
        data: { 
            transaction: 'generate country options',
            multiple : true
        }
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#state-table');
    initializeExportFeature('state');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_country').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-state')){
            const transaction   = 'delete multiple state';
            const state_id      = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                        .filter(checkbox => checkbox.checked)
                                        .map(checkbox => checkbox.value);

            if (state_id.length === 0) {
                showNotification('Deletion Multiple States Error', 'Please select the states you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple States Deletion',
                text: 'Are you sure you want to delete these states?',
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
                state_id.forEach(id => formData.append('state_id[]', id));

                const response = await fetch('./app/Controllers/StateController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#state-table');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete states: ${error.message}`);
            }
        }
    });
});