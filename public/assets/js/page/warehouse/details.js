import { disableButton, enableButton, generateDropdownOptions, resetForm } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link     = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const warehouse_id  = document.getElementById('details-id')?.textContent.trim();
    
    const displayDetails = async () => {
        const transaction = 'fetch warehouse details';

        try {
            resetForm('warehouse_form');

            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('warehouse_id', warehouse_id);

            const response = await fetch('./app/Controllers/WarehouseController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

            const data = await response.json();

            if (data.success) {
                document.getElementById('warehouse_name').value     = data.warehouseName || '';
                document.getElementById('short_name').value         = data.shortName || '';
                document.getElementById('contact_person').value     = data.contactPerson || '';
                document.getElementById('address').value            = data.address || '';
                document.getElementById('phone').value              = data.phone || '';
                document.getElementById('telephone').value          = data.telephone || '';
                document.getElementById('email').value              = data.email || '';

                $('#city_id').val(data.cityID || '').trigger('change');
                $('#warehouse_type_id').val(data.warehouseTypeId || '').trigger('change');
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
            { url: './app/Controllers/CityController.php', selector: '#city_id', transaction: 'generate city options' },
            { url: './app/Controllers/WarehouseTypeController.php', selector: '#warehouse_type_id', transaction: 'generate warehouse type options' }
        ];
        
        for (const cfg of dropdownConfigs) {
            await generateDropdownOptions({
                url: cfg.url,
                dropdownSelector: cfg.selector,
                data: { transaction: cfg.transaction }
            });
        }

        await displayDetails();
    })();

    attachLogNotesHandler('#log-notes-main', '#details-id', 'warehouse');
    
    $('#warehouse_form').validate({
        rules: {
            warehouse_name: { required: true },
            address: {required: true },
            city_id: { required: true },
            warehouse_type_id: { required: true }
        },
        messages: {
            warehouse_name: { required: 'Enter the display name' },
            address: { required: 'Enter the address' },
            city_id: { required: 'Choose the city' },
            warehouse_type_id: { required: 'Choose the warehouse type' }
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

            const transaction = 'save warehouse';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('warehouse_id', warehouse_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/WarehouseController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save warehouse failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-data');
                    displayDetails();
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

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#delete-warehouse')){
            const transaction = 'delete warehouse';

            const result = await Swal.fire({
                title: 'Confirm Warehouse Deletion',
                text: 'Are you sure you want to delete this warehouse?',
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
                    formData.append('warehouse_id', warehouse_id);

                    const response = await fetch('./app/Controllers/WarehouseController.php', {
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
                    handleSystemError(error, 'fetch_failed', `Failed to delete warehouse: ${error.message}`);
                }
            }
        }

        if (event.target.closest('#archive-warehouse')){
            const transaction = 'update warehouse archive';

            Swal.fire({
                title: 'Confirm Warehouse Archive',
                text: 'Are you sure you want to unarchive this warehouse?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Archive',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-danger mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            }).then(async (result) => {
                if (!result.value) return;

                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('warehouse_id', warehouse_id);

                try {
                    const response = await fetch('./app/Controllers/WarehouseController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.reload();
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
            });
        }

        if (event.target.closest('#unarchive-warehouse')){
            const transaction = 'update warehouse unarchive';

            Swal.fire({
                title: 'Confirm Warehouse Unarchive',
                text: 'Are you sure you want to archive this warehouse?',
                icon: 'info',
                showCancelButton: true,
                confirmButtonText: 'Unarchive',
                cancelButtonText: 'Cancel',
                customClass: {
                    confirmButton: 'btn btn-success mt-2',
                    cancelButton: 'btn btn-secondary ms-2 mt-2'
                },
                buttonsStyling: false
            }).then(async (result) => {
                if (!result.value) return;

                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('warehouse_id', warehouse_id);

                try {
                    const response = await fetch('./app/Controllers/WarehouseController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        setNotification(data.title, data.message, data.message_type);
                        window.location.reload();
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
            });
        }
    });
});