import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#product-category-table',
        ajaxUrl: './app/Controllers/ProductCategoryController.php',
        transaction: 'generate product category table',
        ajaxData: {
            filter_by_parent_category: $('#filter_by_parent_category').val(),
            filter_by_costing_method: $('#filter_by_costing_method').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'PRODUCT_CATEGORY_NAME' },
            { data: 'PARENT_CATEGORY_NAME' },
            { data: 'COSTING_METHOD' },
            { data: 'DISPLAY_ORDER' }
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
        url: './app/Controllers/ProductCategoryController.php',
        dropdownSelector: '#filter_by_parent_category',
        data: { transaction: 'generate product category options' , multiple : true }
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#product-category-table');
    initializeExportFeature('product_category');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_parent_category').val(null).trigger('change');
            $('#filter_by_costing_method').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-product-category')){
            const transaction           = 'delete multiple product category';
            const product_category_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                                .filter(el => el.checked)
                                                .map(el => el.value);

            if (product_category_id.length === 0) {
                showNotification('Deletion Multiple Product Categories Error', 'Please select the categories you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Product Categories Deletion',
                text: 'Are you sure you want to delete these categories?',
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
                product_category_id.forEach(id => formData.append('product_category_id[]', id));

                const response = await fetch('./app/Controllers/ProductCategoryController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Deletion failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#product-category-table');
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
        }
    });
});