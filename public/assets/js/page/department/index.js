import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#department-table',
        ajaxUrl: './app/Controllers/DepartmentController.php',
        transaction: 'generate department table',
        ajaxData: {
            filter_by_parent_department: $('#filter_by_parent_department').val(),
            filter_by_manager: $('#filter_by_manager').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'DEPARTMENT_NAME' },
            { data: 'PARENT_DEPARTMENT_NAME' },
            { data: 'MANAGER_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 },
            { width: 'auto', targets: 2, responsivePriority: 3 },
            { width: 'auto', targets: 3, responsivePriority: 4 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });

    const dropdownConfigs = [
        { url: './app/Controllers/DepartmentController.php', selector: '#filter_by_parent_department', transaction: 'generate department options' },
        { url: './app/Controllers/EmployeeController.php', selector: '#filter_by_manager', transaction: 'generate employee options' }
    ];
    
    dropdownConfigs.forEach(cfg => {
        generateDropdownOptions({
            url: cfg.url,
            dropdownSelector: cfg.selector,
            data: { transaction: cfg.transaction, multiple : true }
        });
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#department-table');
    initializeExportFeature('department');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_parent_department').val(null).trigger('change');
            $('#filter_by_manager').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-department')){
            const transaction       = 'delete multiple department';
            const department_id     = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                        .filter(el => el.checked)
                                        .map(el => el.value);

            if (department_id.length === 0) {
                showNotification('Deletion Multiple Departments Error', 'Please select the departments you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Departments Deletion',
                text: 'Are you sure you want to delete these departments?',
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
                department_id.forEach(id => formData.append('department_id[]', id));

                const response = await fetch('./app/Controllers/DepartmentController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Deletion failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#department-table');
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