import { disableButton, enableButton, generateDualListBox, resetForm } from '../../utilities/form-utilities.js';
import { initializeDatatable, initializeSubDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { attachLogNotesHandler, attachLogNotesClassHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link     = document.getElementById('page-link').getAttribute('href') || 'apps.php';
    const role_id       = document.getElementById('details-id').textContent.trim();

    const displayDetails = async () => {
        const transaction = 'fetch role details';

        try {
            resetForm('role_form');

            const formData = new URLSearchParams();
            formData.append('role_id', role_id);
            formData.append('transaction', transaction);

            const response = await fetch('./app/Controllers/RoleController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('role_name').value          = data.roleName || '';
                document.getElementById('role_description').value   = data.roleDescription || '';
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

    initializeDatatable({
        selector: '#menu-item-permission-table',
        ajaxUrl: './app/Controllers/RoleController.php',
        transaction: 'generate role assigned menu item table',
        ajaxData: {
            role_id: role_id
        },
        columns: [
            { data: 'MENU_ITEM_NAME' },
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

    initializeDatatable({
        selector: '#system-action-permission-table',
        ajaxUrl: './app/Controllers/RoleController.php',
        transaction: 'generate role assigned system action table',
        ajaxData: {
            role_id: role_id
        },
        columns: [
            { data: 'SYSTEM_ACTION_NAME' },
            { data: 'ACCESS' },
            { data: 'ACTION' }
        ],
        columnDefs: [
            { width: 'auto', targets: 0, responsivePriority: 1 },
            { width: 'auto', bSortable: false, targets: 1, responsivePriority: 2 },
            { width: '5%', bSortable: false, targets: 2, responsivePriority: 1 }
        ],
        order : [[0, 'asc']]
    });

    initializeSubDatatableControls('#menu-item-permission-datatable-search', '#menu-item-permission-datatable-length', '#menu-item-permission-table');
    initializeSubDatatableControls('#system-action-permission-datatable-search', '#system-action-permission-datatable-length', '#system-action-permission-table');
    attachLogNotesHandler('#log-notes-main', '#details-id', 'role');
    displayDetails();

    $('#role_form').validate({
        rules: {
            role_name: { required: true },
            role_description: { required: true }
        },
        messages: {
            role_name: { required: 'Enter the display name' },
            role_description: { required: 'Enter the description' }
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
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.removeClass('is-invalid');
        },
        submitHandler: async (form, event) => {
            event.preventDefault();

            const transaction = 'save role';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('role_id', role_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/RoleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                } else {
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

    $('#menu_item_permission_assignment_form').validate({
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
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.removeClass('is-invalid');
        },
        submitHandler: async (form, event) => {
            event.preventDefault();

            const transaction = 'save role menu item permission';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('role_id', role_id);

            disableButton('submit-menu-item-assignment');

            try {
                const response = await fetch('./app/Controllers/RoleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Request failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-menu-item-assignment');
                    reloadDatatable('#menu-item-permission-table');
                    $('#menu-item-permission-assignment-modal').modal('hide');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-menu-item-assignment');
                }
            } catch (error) {
                enableButton('submit-menu-item-assignment');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#system_action_permission_assignment_form').validate({
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
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.removeClass('is-invalid');
        },
        submitHandler: async (form, event) => {
            event.preventDefault();

            const transaction = 'save role system action permission';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('role_id', role_id);

            disableButton('submit-system-action-assignment');

            try {
                const response = await fetch('./app/Controllers/RoleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Request failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-system-action-assignment');
                    reloadDatatable('#system-action-permission-table');
                    $('#system-action-permission-assignment-modal').modal('hide');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-system-action-assignment');
                }
            } catch (error) {
                enableButton('submit-system-action-assignment');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#delete-role')){
            const transaction = 'delete role';

            Swal.fire({
                title: 'Confirm Role Deletion',
                text: 'Are you sure you want to delete this role?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Delete',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            }).then(async (result) => {
                if (!result.value) return;

                try {
                    const formData = new URLSearchParams();
                    formData.append('transaction', transaction);
                    formData.append('role_id', role_id);

                    const response = await fetch('./app/Controllers/RoleController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);
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
                    handleSystemError(error, 'fetch_failed', `Delete role failed: ${error.message}`);
                }
            });
        }

        if (event.target.closest('#assign-menu-item-permission')){
            generateDualListBox({
                url: './app/Controllers/RoleController.php',
                selectSelector: 'menu_item_id',
                data: { 
                    transaction: 'generate role menu item dual listbox options',
                    role_id: role_id
                }
            });
        }

        if (event.target.closest('#assign-menu-item-permission')){
            generateDualListBox({
                url: './app/Controllers/RoleController.php',
                selectSelector: 'menu_item_id',
                data: { 
                    transaction: 'generate role menu item dual listbox options',
                    role_id: role_id
                }
            });
        }
        
        if (event.target.closest('.update-menu-item-permission')){
            const transaction           = 'update role menu item permission';
            const button                = event.target.closest('.update-menu-item-permission');
            const role_permission_id    = button.dataset.rolePermissionId;
            const access_type           = button.dataset.accessType;
            const access                = button.checked ? '1' : '0';

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('role_permission_id', role_permission_id);
                formData.append('access_type', access_type);
                formData.append('access', access);

                const response = await fetch('./app/Controllers/RoleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed: ${response.status}`);

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
                handleSystemError(error, 'fetch_failed', `Update menu item permission failed: ${error.message}`);
            }
        }

        if (event.target.closest('.delete-menu-item-permission')){
            const transaction           = 'delete role menu item permission';
            const button                = event.target.closest('.delete-menu-item-permission');
            const role_permission_id    = button.dataset.rolePermissionId;

            Swal.fire({
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
            }).then(async (result) => {
                if (!result.value) return;

                try {
                    const formData = new URLSearchParams();
                    formData.append('transaction', transaction);
                    formData.append('role_permission_id', role_permission_id);

                    const response = await fetch('./app/Controllers/RoleController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        reloadDatatable('#menu-item-permission-table');
                    }
                    else if (data.invalid_session) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.href = data.redirect_link;
                    }
                    else {
                        showNotification(data.title, data.message, data.message_type);
                    }
                } catch (error) {
                    handleSystemError(error, 'fetch_failed', `Delete menu item permission failed: ${error.message}`);
                }
            });
        }

        if (event.target.closest('.view-menu-item-permission-log-notes')){
            const button                = event.target.closest('.view-menu-item-permission-log-notes');
            const role_permission_id    = button.dataset.rolePermissionId;
            attachLogNotesClassHandler('role_permission', role_permission_id);
        }

        if (event.target.closest('#assign-system-action-permission')){
            generateDualListBox({
                url: './app/Controllers/RoleController.php',
                selectSelector: 'system_action_id',
                data: { 
                    transaction: 'generate role system action dual listbox options',
                    role_id: role_id
                }
            });
        }        

        if (event.target.closest('.update-system-action-permission')){
            const transaction           = 'update role system action permission';
            const button                = event.target.closest('.update-system-action-permission');
            const role_permission_id    = button.dataset.rolePermissionId;
            const access_type           = button.dataset.accessType;
            const access                = button.checked ? '1' : '0';

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('role_permission_id', role_permission_id);
                formData.append('access_type', access_type);
                formData.append('access', access);

                const response = await fetch('./app/Controllers/RoleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed: ${response.status}`);

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
                handleSystemError(error, 'fetch_failed', `Update system action permission failed: ${error.message}`);
            }
        }        

        if (event.target.closest('.delete-system-action-permission')){
            const transaction           = 'delete role system action permission';
            const button                = event.target.closest('.delete-system-action-permission');
            const role_permission_id    = button.dataset.rolePermissionId;

            Swal.fire({
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
            }).then(async (result) => {
                if (!result.value) return;

                try {
                    const formData = new URLSearchParams();
                    formData.append('transaction', transaction);
                    formData.append('role_permission_id', role_permission_id);

                    const response = await fetch('./app/Controllers/RoleController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);
                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        reloadDatatable('#system-action-permission-table');
                    }
                    else if (data.invalid_session) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.href = data.redirect_link;
                    }
                    else {
                        showNotification(data.title, data.message, data.message_type);
                    }
                } catch (error) {
                    handleSystemError(error, 'fetch_failed', `Delete system action permission failed: ${error.message}`);
                }
            });
        }

        if (event.target.closest('.view-system-action-permission-log-notes')){
            const button                            = event.target.closest('.view-system-action-permission-log-notes');
            const role_system_action_permission_id  = button.dataset.rolePermissionId;
            attachLogNotesClassHandler('role_system_action_permission', role_system_action_permission_id);
        }
    });
});