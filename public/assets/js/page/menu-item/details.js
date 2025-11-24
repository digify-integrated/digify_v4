import { disableButton, enableButton, generateDropdownOptions, generateDualListBox, resetForm } from '../../utilities/form-utilities.js';
import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { attachLogNotesHandler, attachLogNotesClassHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link     = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const menu_item_id  = document.getElementById('details-id')?.textContent.trim();
    
    const displayDetails = async () => {
        const transaction = 'fetch menu item details';

        try {
            resetForm('menu_item_form');

            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('menu_item_id', menu_item_id);

            const response = await fetch('./app/Controllers/MenuItemController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

            const data = await response.json();

            if (data.success) {
                document.getElementById('menu_item_name').value     = data.menuItemName || '';
                document.getElementById('order_sequence').value     = data.orderSequence || '';
                document.getElementById('menu_item_url').value      = data.menuItemURL || '';

                $('#app_module_id').val(data.appModuleID || '').trigger('change');
                $('#parent_id').val(data.parentID || '').trigger('change');
                $('#menu_item_icon').val(data.menuItemIcon || '').trigger('change');
                $('#table_name').val(data.tableName || '').trigger('change');
            } 
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location = page_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    };

    (async () => {
        const dropdownConfigs = [
            { url: './app/Controllers/AppModuleController.php', selector: '#app_module_id', transaction: 'generate app module options' },
            { url: './app/Controllers/MenuItemController.php', selector: '#parent_id', transaction: 'generate menu item options', extraData: { menu_item_id } },
            { url: './app/Controllers/ExportController.php', selector: '#table_name', transaction: 'generate export table options' },
        ];
        
        for (const cfg of dropdownConfigs) {
            await generateDropdownOptions({
                url: cfg.url,
                dropdownSelector: cfg.selector,
                data: { 
                    transaction: cfg.transaction, 
                    ...(cfg.extraData || {})
                }
            });
        }

        await displayDetails();
    })();

    initializeDatatable({
        selector: '#role-permission-table',
        ajaxUrl: './app/Controllers/MenuItemController.php',
        transaction: 'generate menu item assigned role table',
        ajaxData: {
            menu_item_id: menu_item_id
        },
        columns: [
            { data: 'ROLE_NAME' },
            { data: 'READ_ACCESS' },
            { data: 'CREATE_ACCESS' },
            { data: 'WRITE_ACCESS' },
            { data: 'DELETE_ACCESS' },
            { data: 'IMPORT_ACCESS' },
            { data: 'EXPORT_ACCESS' },
            { data: 'LOG_NOTES_ACCESS' },
            { data: 'ACTION' }
        ],
        columnDefs: [
            { width: 'auto', targets: 0, responsivePriority: 1 },
            { width: 'auto', bSortable: false, targets: 1, responsivePriority: 2 },
            { width: 'auto', bSortable: false, targets: 2, responsivePriority: 3 },
            { width: 'auto', bSortable: false, targets: 3, responsivePriority: 4 },
            { width: 'auto', bSortable: false, targets: 4, responsivePriority: 5 },
            { width: 'auto', bSortable: false, targets: 5, responsivePriority: 6 },
            { width: 'auto', bSortable: false, targets: 6, responsivePriority: 7 },
            { width: 'auto', bSortable: false, targets: 7, responsivePriority: 8 },
            { width: 'auto', bSortable: false, targets: 8, responsivePriority: 1 }
        ],
        order : [[0, 'asc']]
    });

    initializeDatatableControls('#role-permission-table');
    attachLogNotesHandler('#log-notes-main', '#details-id', 'menu_item');
    
    $('#menu_item_form').validate({
        rules: {
            menu_item_name: { required: true },
            app_module_id: { required: true },
            order_sequence: { required: true }
        },
        messages: {
            menu_item_name: { required: 'Enter the display name' },
            app_module_id: { required: 'Choose the app module' },
            order_sequence: { required: 'Enter the order sequence' }
        },
        errorPlacement: (error, element) => {
            showNotification('Action Needed: Issue Detected', error.text(), 'error', 2500);
        },
        highlight: (element) => {
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.addClass('is-invalid');
        },
        unhighlight: (element) => {
            const $element  = $(element);
            const $target   = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.removeClass('is-invalid');
        },
        submitHandler: async (form, event) => {
            event.preventDefault();

            const transaction = 'save menu item';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('menu_item_id', menu_item_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/MenuItemController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save menu item failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                }
                else if(data.invalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                }
            } catch (error) {
                enableButton('submit-data');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });
    
    $('#role_permission_assignment_form').validate({
        errorPlacement: (error, element) => {
            showNotification('Action Needed: Issue Detected', error.text(), 'error', 2500);
        },
        highlight: (element) => {
            const $element  = $(element);
            const $target   = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.addClass('is-invalid');
        },
        unhighlight: (element) => {
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.removeClass('is-invalid');
        },
        submitHandler: async (form, event) => {
            event.preventDefault();

            const transaction = 'save menu item role permission';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('menu_item_id', menu_item_id);

            disableButton('submit-assignment');

            try {
                const response = await fetch('./app/Controllers/MenuItemController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save role failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-assignment');
                    reloadDatatable('#role-permission-table');
                    $('#role-permission-assignment-modal').modal('hide');
                }
                else if(data.invalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-assignment');
                }
            } catch (error) {
                enableButton('submit-assignment');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#delete-menu-item')){
            const transaction = 'delete menu item';

            if (!menu_item_id) {
                showNotification('Error', 'Menu item ID not found', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Menu Item Deletion',
                text: 'Are you sure you want to delete this menu item?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            });

            if (result.value) {
                try {
                    const formData = new URLSearchParams();
                    formData.append('transaction', transaction);
                    formData.append('menu_item_id', menu_item_id);

                    const response = await fetch('./app/Controllers/MenuItemController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location = page_link;
                    }
                    else if (data.invalid_session) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.href = data.redirect_link;
                    }
                    else {
                        showNotification(data.title, data.message, data.message_type);
                    }
                } catch (error) {
                    handleSystemError(error, 'fetch_failed', `Failed to delete menu item: ${error.message}`);
                }
            }
        }

        if (event.target.closest('#assign-role-permission')){
            generateDualListBox({
                url: './app/Controllers/MenuItemController.php',
                selectSelector: 'role_id',
                data: {
                    transaction: 'generate menu item role dual listbox options',
                    menu_item_id: menu_item_id
                }
            });
        }

        if (event.target.closest('.update-role-permission')){
            const transaction           = 'update menu item role permission';
            const button                = event.target.closest('.update-role-permission');
            const role_permission_id    = button.dataset.rolePermissionId;
            const access_type           = button.dataset.accessType;
            const access                = button.checked ? '1' : '0';

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('role_permission_id', role_permission_id);
                formData.append('access_type', access_type);
                formData.append('access', access);

                const response = await fetch('./app/Controllers/MenuItemController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (!data.success) {
                    if (data.invalid_session) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.href = data.redirect_link;
                    }
                    else {
                        showNotification(data.title, data.message, data.message_type);
                    }
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to update role permission: ${error.message}`);
            }
        }

        if (event.target.closest('.delete-role-permission')){
            const transaction           = 'delete menu item role permission';
            const button                = event.target.closest('.delete-role-permission');
            const role_permission_id    = button.dataset.rolePermissionId;

            const result = await Swal.fire({
                title: 'Confirm Role Permission Deletion',
                text: 'Are you sure you want to delete this role permission?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            });

            if (result.value) {
                try {
                    const formData = new URLSearchParams();
                    formData.append('transaction', transaction);
                    formData.append('role_permission_id', role_permission_id);

                    const response = await fetch('./app/Controllers/MenuItemController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        reloadDatatable('#role-permission-table');
                    }
                    else if (data.invalid_session) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.href = data.redirect_link;
                    }
                    else{
                        showNotification(data.title, data.message, data.message_type);
                    }
                } catch (error) {
                    handleSystemError(error, 'fetch_failed', `Failed to delete role permission: ${error.message}`);
                }
            }
        }

        if (event.target.closest('.view-role-permission-log-notes')){
            const button                = event.target.closest('.view-role-permission-log-notes');
            const role_permission_id    = button.dataset.rolePermissionId;
            attachLogNotesClassHandler('role_permission', role_permission_id);
        }
    });
});