import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';
import { generateDropdownOptions } from '../../utilities/form-utilities.js';

document.addEventListener('DOMContentLoaded', () => {
    let isFetching = false;
    let hasQueuedRequest = false;
    let offset = 0;
    const LIMIT = 16;

    const datatableConfig = () => ({
        selector: '#employee-table',
        ajaxUrl: './app/Controllers/EmployeeController.php',
        transaction: 'generate employee table',
        ajaxData: {
            filter_by_company: document.querySelector('#filter_by_company')?.value || [],
            filter_by_department: document.querySelector('#filter_by_department')?.value || [],
            filter_by_job_position: document.querySelector('#filter_by_job_position')?.value || [],
            filter_by_employee_status: document.querySelector('#filter_by_employee_status')?.value || [],
            filter_by_work_location: document.querySelector('#filter_by_work_location')?.value || [],
            filter_by_employment_type: document.querySelector('#filter_by_employment_type')?.value || [],
            filter_by_gender: document.querySelector('#filter_by_gender')?.value || []
        },
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'EMPLOYEE' },
            { data: 'DEPARTMENT' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 },
            { width: 'auto', targets: 2, responsivePriority: 3 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });

    initializeDatatable(datatableConfig());
    initializeDatatableControls('#employee-table');
    initializeExportFeature('employee');

    const containerId = 'employee-card';
    const container = document.querySelector(`#${containerId}`);

    const dropdownConfigs = [
        { url: './app/Controllers/CompanyController.php', selector: '#filter_by_company', transaction: 'generate company options' },
        { url: './app/Controllers/DepartmentController.php', selector: '#filter_by_department', transaction: 'generate department options' },
        { url: './app/Controllers/JobPositionController.php', selector: '#filter_by_job_position', transaction: 'generate job position options' },
        { url: './app/Controllers/WorkLocationController.php', selector: '#filter_by_work_location', transaction: 'generate work location options' },
        { url: './app/Controllers/EmploymentTypeController.php', selector: '#filter_by_employment_type', transaction: 'generate employment type options' },
        { url: './app/Controllers/GenderController.php', selector: '#filter_by_gender', transaction: 'generate gender options' }
    ];

    dropdownConfigs.forEach(cfg => {
        generateDropdownOptions({
            url: cfg.url,
            dropdownSelector: cfg.selector,
            data: { transaction: cfg.transaction, multiple: true }
        });
    });

    const spinner = document.createElement('div');
    spinner.id = 'loading-spinner';
    spinner.className = 'text-center mt-10 d-none';
    spinner.innerHTML = `
        <span>
            <span class="spinner-grow spinner-grow-md align-middle ms-0"></span>
        </span>
    `;
    container?.appendChild(spinner);

    function showSpinner() {
        spinner.classList.remove('d-none');
    }

    function hideSpinner() {
        spinner.classList.add('d-none');
    }

    const fetchEmployeeCards = async ({ clearExisting = false } = {}) => {
        if (isFetching) {
            hasQueuedRequest = true;
            return;
        }
        isFetching = true;
        showSpinner();

        try {
            if (clearExisting) {
                container.innerHTML = '';
                container.appendChild(spinner);
                container.appendChild(sentinel);
                offset = 0;
            }

            const payload = {
                page_id: document.querySelector('#page-id')?.value,
                page_link: document.querySelector('#page-link')?.getAttribute('href'),
                transaction: 'generate employee card',
                limit: LIMIT,
                offset,
                search_value: document.querySelector('#datatable-search')?.value || '',
                filter_by_company: document.querySelector('#filter_by_company')?.value || [],
                filter_by_department: document.querySelector('#filter_by_department')?.value || [],
                filter_by_job_position: document.querySelector('#filter_by_job_position')?.value || [],
                filter_by_employee_status: document.querySelector('#filter_by_employee_status')?.value || [],
                filter_by_work_location: document.querySelector('#filter_by_work_location')?.value || [],
                filter_by_employment_type: document.querySelector('#filter_by_employment_type')?.value || [],
                filter_by_gender: document.querySelector('#filter_by_gender')?.value || []
            };

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: new URLSearchParams(payload)
            });

            if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);

            const data = await response.json();

            if (!Array.isArray(data) || data.length === 0) {
                stopInfiniteScroll();
                return;
            }

            const htmlString = data.map(card => card.EMPLOYEE_CARD).join('');
            sentinel.insertAdjacentHTML('beforebegin', htmlString);

            offset += data.length;

            if (data.length < LIMIT) {
                stopInfiniteScroll();
            } else {
                ensureScrollable();
            }

        } catch (error) {
            console.error('Error fetching employee cards:', error);
        } finally {
            isFetching = false;
            hideSpinner();

            if (hasQueuedRequest) {
                hasQueuedRequest = false;
                fetchEmployeeCards({ clearExisting: false });
            }
        }
    };

    const sentinel  = document.createElement('div');
    sentinel.id     = 'scroll-sentinel';
    container.appendChild(sentinel);

    const observer = new IntersectionObserver(entries => {
        if (entries.some(entry => entry.isIntersecting)) {
            fetchEmployeeCards();
        }
    }, { rootMargin: '300px' });

    observer.observe(sentinel);

    function stopInfiniteScroll() {
        observer.disconnect();
    }

    async function ensureScrollable() {
        if (container.scrollHeight <= window.innerHeight && !isFetching) {
            await fetchEmployeeCards();
        }
    }

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#apply-filter')) {
            observer.observe(sentinel);
            fetchEmployeeCards({ clearExisting: true });

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#reset-filter')) {
            $('#filter_by_company').val(null).trigger('change');
            $('#filter_by_department').val(null).trigger('change');
            $('#filter_by_job_position').val(null).trigger('change');
            $('#filter_by_job_position').val(null).trigger('change');
            $('#filter_by_employee_status').val(null).trigger('change');
            $('#filter_by_work_location').val(null).trigger('change');
            $('#filter_by_employment_type').val(null).trigger('change');

            observer.observe(sentinel);
            fetchEmployeeCards({ clearExisting: true });

            initializeDatatable(datatableConfig());
        }

        if (event.target.closest('#delete-employee')) {
            const transaction   = 'delete multiple employee';
            const employee_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                            .filter(el => el.checked)
                                            .map(el => el.value);

            if (employee_id.length === 0) {
                showNotification('Deletion Multiple Employees Error', 'Please select the employees you wish to delete.', 'error');
                return;
            }

            const result = await Swal.fire({
                title: 'Confirm Multiple Employees Deletion',
                text: 'Are you sure you want to delete these employees?',
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
                employee_id.forEach(id => formData.append('employee_id[]', id));

                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Deletion failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    observer.observe(sentinel);
                    fetchEmployeeCards({ clearExisting: true });

                    reloadDatatable('#employee-table');
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

    document.addEventListener('keyup', event => {
        const employeeTable     = $('#employee-table').DataTable();
        const searchInput       = event.target.closest('#datatable-search');

        if (searchInput) {
            employeeTable.search(searchInput.value).draw();

            observer.observe(sentinel);
            fetchEmployeeCards({ clearExisting: true });
        }
    });

    document.addEventListener('change', event => {
        const employeeTable    = $('#employee-table').DataTable();
        const lengthSelect     = event.target.closest('#datatable-length');

        if (lengthSelect) {
            const newLength = lengthSelect.value;
            employeeTable.page.len(newLength).draw();
        }
    });

    fetchEmployeeCards({ clearExisting: true });
});
