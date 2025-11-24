import { initializeDatatable, initializeDatatableControls, generateDropdownOptions, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#pricelist-table',
        ajaxUrl: './app/Controllers/ProductController.php',
        transaction: 'generate pricelist table',
        ajaxData: {
            filter_by_product: $('#filter_by_product').val(),
            filter_by_discount_type: $('#filter_by_discount_type').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'PRODUCT' },
            { data: 'DISCOUNT_TYPE' },
            { data: 'FIXED_PRICE' },
            { data: 'MIN_QUANTITY' },
            { data: 'VALIDITY' },
            { data: 'REMARKS' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 },
            { width: 'auto', targets: 2, responsivePriority: 3 },
            { width: 'auto', targets: 3, responsivePriority: 4 },
            { width: 'auto', targets: 4, responsivePriority: 5 },
            { width: 'auto', targets: 5, responsivePriority: 6 },
            { width: 'auto', targets: 6, responsivePriority: 7 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });
    
    generateDropdownOptions({
        url: './app/Controllers/ProductController.php',
        dropdownSelector: '#filter_by_product',
        data: { transaction: 'generate product options', multiple : true }
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#pricelist-table');
    initializeExportFeature('pricelist');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_product').val(null).trigger('change');
            $('#filter_by_discount_type').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-pricelist')){
            const transaction   = 'delete multiple product pricelist';
            const product_pricelist_id  = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                    .filter(checkbox => checkbox.checked)
                                    .map(checkbox => checkbox.value);

            if (product_pricelist_id.length === 0) {
                showNotification('Deletion Multiple Pricelists Error', 'Please select the pricelists you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Pricelists Deletion',
                text: 'Are you sure you want to delete these pricelists?',
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
                product_pricelist_id.forEach(id => formData.append('product_pricelist_id[]', id));

                const response = await fetch('./app/Controllers/ProductController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#pricelist-table');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete pricelists: ${error.message}`);
            }
        }
    });
});