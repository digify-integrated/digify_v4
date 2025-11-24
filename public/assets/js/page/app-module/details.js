import { disableButton, enableButton, generateDropdownOptions, resetForm } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const app_module_id     = document.getElementById('details-id')?.textContent.trim();
    const page_link         = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';

    const displayDetails = async () => {
        const transaction = 'fetch app module details';

        try {
            resetForm('app_module_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('app_module_id', app_module_id);

            const response = await fetch('./app/Controllers/AppModuleController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('app_module_name').value            = data.appModuleName || '';
                document.getElementById('app_module_description').value     = data.appModuleDescription || '';
                document.getElementById('order_sequence').value             = data.orderSequence || '';

                $('#menu_item_id').val(data.menuItemID).trigger('change');

                const thumbnail = document.getElementById('app_thumbnail');
                if (thumbnail) thumbnail.style.backgroundImage = `url(${data.appLogo || ''})`;
            }
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = page_link;
            }
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    };
    
    (async () => {
        await generateDropdownOptions({
            url: './app/Controllers/MenuItemController.php',
            dropdownSelector: '#menu_item_id',
            data: { transaction: 'generate menu item options' }
        });

        await displayDetails();
    })();

    attachLogNotesHandler('#log-notes-main', '#details-id', 'app_module');

    $('#app_module_form').validate({
        rules: {
            app_module_name: { required: true },
            app_module_description: { required: true },
            menu_item_id: { required: true },
            order_sequence: { required: true }
        },
        messages: {
            app_module_name: { required: 'Enter the display name' },
            app_module_description: { required: 'Enter the description' },
            menu_item_id: { required: 'Select the default page' },
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
            const $element = $(element);
            const $target = $element.hasClass('select2-hidden-accessible')
                ? $element.next().find('.select2-selection')
                : $element;
            $target.removeClass('is-invalid');
        },
        submitHandler: async (form, event) => {
            event.preventDefault();

            const transaction = 'save app module';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('app_module_id', app_module_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/AppModuleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save app module failed with status: ${response.status}`);
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

    document.addEventListener('click', async (event) => {
        if (!event.target.closest('#delete-app-module')) return;

        const transaction = 'delete app module';

        const result = await Swal.fire({
            title: 'Confirm App Module Deletion',
            text: 'Are you sure you want to delete this app module?',
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

        if (result.isConfirmed) {
            try {
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('app_module_id', app_module_id);

                const response = await fetch('./app/Controllers/AppModuleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = page_link;
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

    document.addEventListener('change', async (event) => {
        if (!event.target.closest('#app_logo')) return;

        const input = event.target;
        if (input.files && input.files.length > 0) {
            const transaction = 'update app module logo';

            if (!app_module_id) {
                showNotification('Error', 'App module ID not found', 'error');
                return;
            }

            const formData = new FormData();
            formData.append('transaction', transaction);
            formData.append('app_module_id', app_module_id);
            formData.append('app_logo', input.files[0]);

            try {
                const response = await fetch('./app/Controllers/AppModuleController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
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