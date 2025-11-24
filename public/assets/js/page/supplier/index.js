import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#supplier-table',
        ajaxUrl: './app/Controllers/SupplierController.php',
        transaction: 'generate supplier table',
        ajaxData: {
            filter_by_city: $('#filter_by_city').val(),
            filter_by_state: $('#filter_by_state').val(),
            filter_by_country: $('#filter_by_country').val(),
            filter_by_supplier_status: $('#filter_by_supplier_status').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'SUPPLIER_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });

    const dropdownConfigs = [
        { url: './app/Controllers/CityController.php', selector: '#filter_by_city', transaction: 'generate filter city options' },
        { url: './app/Controllers/StateController.php', selector: '#filter_by_state', transaction: 'generate state options' },
        { url: './app/Controllers/CountryController.php', selector: '#filter_by_country', transaction: 'generate country options' }
    ];
    
    dropdownConfigs.forEach(cfg => {
        generateDropdownOptions({
            url: cfg.url,
            dropdownSelector: cfg.selector,
            data: { transaction: cfg.transaction, multiple : true }
        });
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#supplier-table');
    initializeExportFeature('supplier');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_city').val(null).trigger('change');
            $('#filter_by_state').val(null).trigger('change');
            $('#filter_by_country').val(null).trigger('change');
            $('#filter_by_supplier_status').val('Active').trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-supplier')){
            const transaction   = 'delete multiple supplier';
            const supplier_id    = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                    .filter(checkbox => checkbox.checked)
                                    .map(checkbox => checkbox.value);

            if (supplier_id.length === 0) {
                showNotification('Deletion Multiple Suppliers Error', 'Please select the suppliers you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Suppliers Deletion',
                text: 'Are you sure you want to delete these suppliers?',
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
                supplier_id.forEach(id => formData.append('supplier_id[]', id));

                const response = await fetch('./app/Controllers/SupplierController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#supplier-table');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete suppliers: ${error.message}`);
            }
        }
    });
});