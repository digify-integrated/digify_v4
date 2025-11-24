import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#user-account-table',
        ajaxUrl: './app/Controllers/UserAccountController.php',
        transaction: 'generate user account table',
        ajaxData: {
            filter_by_user_account_status: $('#filter_by_user_account_status').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'USER_ACCOUNT' },
            { data: 'USER_ACCOUNT_STATUS' },
            { data: 'LAST_CONNECTION_DATE' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 },
            { width: 'auto', targets: 2, responsivePriority: 3 },
            { width: 'auto', targets: 3, type: 'date', responsivePriority: 4 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#user-account-table');
    initializeExportFeature('user_account');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_user_account_status').val(null).trigger('change');
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#activate-user-account')) {
            const transaction       = 'activate multiple user account';
            const checkboxes        = document.querySelectorAll('.datatable-checkbox-children:checked');
            const user_account_id   = Array.from(checkboxes).map(cb => cb.value);

            if (user_account_id.length === 0) {
                showNotification(
                    'Activation Multiple User Account Error',
                    'Please select the user accounts you wish to activate.',
                    'error'
                );
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple User Accounts Activation',
                text: 'Are you sure you want to activate these user accounts?',
                icon: 'info',
                showCancelButton: !0,
                confirmButtonText: 'Activate',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-success',
                    cancelButton: 'btn btn-secondary'
                },
                buttonsStyling: false
            });

            if (!result.value) return;

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                user_account_id.forEach(id => formData.append('user_account_id[]', id));

                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#user-account-table');
                }
                else if(datainvalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to activate multiple user account: ${error.message}`);
            }
        }

        if (event.target.closest('#deactivate-user-account')) {
            const transaction       = 'deactivate multiple user account';
            const user_account_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                            .filter(checkbox => checkbox.checked)
                                            .map(checkbox => checkbox.value);

            if (user_account_id.length === 0) {
                showNotification(
                    'Deactivation Multiple User Account Error',
                    'Please select the user accounts you wish to deactivate.',
                    'error'
                );
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple User Accounts Deactivation',
                text: 'Are you sure you want to deactivate these user accounts?',
                icon: 'warning',
                showCancelButton: !0,
                confirmButtonText: 'Deactivate',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-success',
                    cancelButton: 'btn btn-secondary'
                },
                buttonsStyling: false
            });

            if (!result.value) return;

            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                user_account_id.forEach(id => formData.append('user_account_id[]', id));

                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#user-account-table');
                }
                else if(datainvalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to deactivate multiple user account: ${error.message}`);
            }
        }

        if (event.target.closest('#delete-user-account')) {
            const transaction       = 'delete multiple user account';
            const user_account_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                            .filter(checkbox => checkbox.checked)
                                            .map(checkbox => checkbox.value);

            if (user_account_id.length === 0) {
                showNotification('Deletion Multiple User Account Error', 'Please select the user accounts you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple User Accounts Deletion',
                text: 'Are you sure you want to delete these user accounts?',
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
                user_account_id.forEach(id => formData.append('user_account_id[]', id));

                const response = await fetch('./app/Controllers/UserAccountController.php', {
                    method: 'POST',                    
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#user-account-table');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete multiple user accounts: ${error.message}`);
            }
        }
    });
});