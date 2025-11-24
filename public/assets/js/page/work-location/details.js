import { disableButton, enableButton, resetForm, generateDropdownOptions } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link         = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const work_location_id  = document.getElementById('details-id')?.textContent.trim();
   
    const displayDetails = async () => {
        const transaction = 'fetch work location details';

        try {
            resetForm('work_location_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('work_location_id', work_location_id);

            const response = await fetch('./app/Controllers/WorkLocationController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('work_location_name').value     = data.workLocationName || '';
                document.getElementById('address').value                = data.address || '';
                document.getElementById('phone').value                  = data.phone || '';
                document.getElementById('telephone').value              = data.telephone || '';
                document.getElementById('email').value                  = data.email || '';

                $('#city_id').val(data.cityID || '').trigger('change');
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
            url: './app/Controllers/CityController.php',
            dropdownSelector: '#city_id',
            data: { 
                transaction: 'generate city options'
            }
        });

        await displayDetails();
    })();

    attachLogNotesHandler('#log-notes-main', '#details-id', 'work_location');

    $('#work_location_form').validate({
        rules: {
            work_location_name: { required: true },
            address: { required: true },
            city_id: { required: true }
        },
        messages: {
            work_location_name: { required: 'Enter the display name' },
            address: { required: 'Enter the address' },
            city_id: { required: 'Choose the city' }
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

            const transaction = 'save work location';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('work_location_id', work_location_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/WorkLocationController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save work location failed with status: ${response.status}`);
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
        if (!event.target.closest('#delete-work-location')) return;

        const transaction = 'delete work location';

        const result = await Swal.fire({
            title: 'Confirm Work Location Deletion',
            text: 'Are you sure you want to delete this work location?',
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
                formData.append('work_location_id', work_location_id);

                const response = await fetch('./app/Controllers/WorkLocationController.php', {
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
});