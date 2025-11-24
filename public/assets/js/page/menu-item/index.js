import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#menu-item-table',
        ajaxUrl: './app/Controllers/MenuItemController.php',
        transaction: 'generate menu item table',
        ajaxData: {
            filter_by_app_module: $('#filter_by_app_module').val(),
            filter_by_parent_menu: $('#filter_by_parent_menu').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'MENU_ITEM_NAME' },
            { data: 'APP_MODULE_NAME' },
            { data: 'PARENT_NAME' },
            { data: 'ORDER_SEQUENCE' }
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

    const dropdownConfigs = [
        { url: './app/Controllers/MenuItemController.php', selector: '#filter_by_parent_menu', transaction: 'generate menu item options' },
        { url: './app/Controllers/AppModuleController.php', selector: '#filter_by_app_module', transaction: 'generate app module options' }
    ];
    
    dropdownConfigs.forEach(cfg => {
        generateDropdownOptions({
            url: cfg.url,
            dropdownSelector: cfg.selector,
            data: { transaction: cfg.transaction, multiple : true }
        });
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#menu-item-table');
    initializeExportFeature('menu_item');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_parent_menu').val(null).trigger('change');
            $('#filter_by_app_module').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-menu-item')){
            const transaction   = 'delete multiple menu item';
            const menu_item_id  = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                        .filter(checkbox => checkbox.checked)
                                        .map(checkbox => checkbox.value);

            if (menu_item_id.length === 0) {
                showNotification('Deletion Multiple Menu Items Error', 'Please select the menu items you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Menu Items Deletion',
                text: 'Are you sure you want to delete these menu items?',
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
                menu_item_id.forEach(id => formData.append('menu_item_id[]', id));

                const response = await fetch('./app/Controllers/MenuItemController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#menu-item-table');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete menu items: ${error.message}`);
            }
        }
    });
});