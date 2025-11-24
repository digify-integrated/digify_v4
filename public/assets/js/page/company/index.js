import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    const datatableConfig = () => ({
        selector: '#company-table',
        ajaxUrl: './app/Controllers/CompanyController.php',
        transaction: 'generate company table',
        ajaxData: {
            filter_by_city: $('#filter_by_city').val(),
            filter_by_state: $('#filter_by_state').val(),
            filter_by_country: $('#filter_by_country').val(),
            filter_by_currency: $('#filter_by_currency').val()
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'COMPANY_NAME' }
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
        { url: './app/Controllers/CountryController.php', selector: '#filter_by_country', transaction: 'generate country options' },
        { url: './app/Controllers/CurrencyController.php', selector: '#filter_by_currency', transaction: 'generate currency options' }
    ];
    
    dropdownConfigs.forEach(cfg => {
        generateDropdownOptions({
            url: cfg.url,
            dropdownSelector: cfg.selector,
            data: { transaction: cfg.transaction, multiple : true }
        });
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#company-table');
    initializeExportFeature('company');

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_city').val(null).trigger('change');
            $('#filter_by_state').val(null).trigger('change');
            $('#filter_by_country').val(null).trigger('change');
            $('#filter_by_currency').val(null).trigger('change');

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-company')){
            const transaction   = 'delete multiple company';
            const company_id    = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                    .filter(checkbox => checkbox.checked)
                                    .map(checkbox => checkbox.value);

            if (company_id.length === 0) {
                showNotification('Deletion Multiple Companies Error', 'Please select the companies you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Companies Deletion',
                text: 'Are you sure you want to delete these companies?',
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
                company_id.forEach(id => formData.append('company_id[]', id));

                const response = await fetch('./app/Controllers/CompanyController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#company-table');
                } 
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                handleSystemError(error, 'fetch_failed', `Failed to delete companies: ${error.message}`);
            }
        }
    });
});