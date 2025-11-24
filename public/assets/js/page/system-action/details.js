import { disableButton, enableButton, generateDualListBox, resetForm } from '../../utilities/form-utilities.js';
import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { attachLogNotesHandler, attachLogNotesClassHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link         = document.getElementById('page-link').getAttribute('href') || 'apps.php';
    const system_action_id  = document.getElementById('details-id')?.textContent.trim() || '';

    const displayDetails = async () => {
        const transaction = 'fetch system action details';

        try {
            resetForm('system_action_form');

            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('system_action_id', system_action_id);

            const response = await fetch('./app/Controllers/SystemActionController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                document.getElementById('system_action_name').value         = data.systemActionName || '';
                document.getElementById('system_action_description').value  = data.systemActionDescription || '';
            } 
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location = page_link;
            } 
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch system action details: ${error.message}`);
        }
    };

    initializeDatatable({
        selector: '#role-permission-table',
        ajaxUrl: './app/Controllers/SystemActionController.php',
        transaction: 'generate system action assigned role table',
        ajaxData: {
            system_action_id: system_action_id
        },
        columns: [
            { data: 'ROLE_NAME' },
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

    initializeDatatableControls('#role-permission-table');
    attachLogNotesHandler('#log-notes-main', '#details-id', 'system_action');
    displayDetails();

    $('#system_action_form').validate({
        rules: {
            system_action_name: { required: true },
            system_action_description: { required: true }
        },
        messages: {
            system_action_name: { required: 'Enter the display name' },
            system_action_description: { required: 'Enter the description' }
        },
        errorPlacement: (error) => {
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

            const transaction = 'save system action';

            disableButton('submit-data');

            try {
                const formData = new URLSearchParams(new FormData(form));
                formData.append('transaction', transaction);
                formData.append('system_action_id', system_action_id);

                const response = await fetch('./app/Controllers/SystemActionController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                }
            } catch (error) {
                enableButton('submit-data');
                handleSystemError(error, 'fetch_failed', `Failed to save system action: ${error.message}`);
            }

            return false;
        }
    });
    
    $('#role_permission_assignment_form').validate({
        errorPlacement: (error) => {
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

            const transaction = 'save system action role permission';

            disableButton('submit-assignment');

            try {
                const formData = new URLSearchParams(new FormData(form));
                formData.append('transaction', transaction);
                formData.append('system_action_id', system_action_id);

                const response = await fetch('./app/Controllers/SystemActionController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-assignment');
                    reloadDatatable('#role-permission-table');
                    $('#role-permission-assignment-modal').modal('hide');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-assignment');
                }
            } catch (error) {
                enableButton('submit-assignment');
                handleSystemError(error, 'fetch_failed', `Failed to save role permission: ${error.message}`);
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#delete-system-action')){
            const transaction = 'delete system action';

            const result = await Swal.fire({
                title: 'Confirm System Action Deletion',
                text: 'Are you sure you want to delete this system action?',
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

            if (!result.value) return;

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('system_action_id', system_action_id);

                const response = await fetch('./app/Controllers/SystemActionController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

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
                handleSystemError(error, 'fetch_failed', `Failed to delete system action: ${error.message}`);
            }
        }

        if (event.target.closest('#assign-role-permission')){
            generateDualListBox({
                url: './app/Controllers/SystemActionController.php',
                selectSelector: 'role_id',
                data: {
                    transaction: 'generate system action role dual listbox options',
                    system_action_id: system_action_id
                }
            }); 
        }

        if (event.target.closest('.update-role-permission')){
            const transaction           = 'update system action role permission';
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

                const response = await fetch('./app/Controllers/SystemActionController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

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
            const transaction           = 'delete system action role permission';
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

            if (!result.value) return;

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('role_permission_id', role_permission_id);

                const response = await fetch('./app/Controllers/SystemActionController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#role-permission-table');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete role permission: ${error.message}`);
            }
        }

        if (event.target.closest('.view-role-permission-log-notes')){
            const button                            = event.target.closest('.view-role-permission-log-notes');
            const role_system_action_permission_id  = button.dataset.rolePermissionId;
            attachLogNotesClassHandler('role_system_action_permission', role_system_action_permission_id);
        }
    });
});