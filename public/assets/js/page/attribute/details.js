import { disableButton, enableButton, resetForm } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler, attachLogNotesClassHandler } from '../../utilities/log-notes.js';
import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link     = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const attribute_id  = document.getElementById('details-id')?.textContent.trim();
    const page_id       = document.getElementById('page-id')?.value || '';

    const displayDetails = async () => {
        const transaction = 'fetch attribute details';

        try {
            resetForm('attribute_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('attribute_id', attribute_id);

            const response = await fetch('./app/Controllers/AttributeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('attribute_name').value         = data.attributeName || '';
                document.getElementById('attribute_description').value  = data.attributeDescription || '';

                $('#variant_creation').val(data.variantCreation || '').trigger('change');
                $('#display_type').val(data.displayType || '').trigger('change');
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

    const displayAttributeValueDetails = async (attribute_value_id) => {
        const transaction = 'fetch attribute value details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('attribute_id', attribute_id);
            formData.append('attribute_value_id', attribute_value_id);

            const response = await fetch('./app/Controllers/AttributeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                $('#attribute_value_id').val(attribute_value_id);
                $('#attribute_value_name').val(data.attributeValueName || '');
            } 
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location = page_link;
            } 
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch employee details: ${error.message}`);
        }
    }

    attachLogNotesHandler('#log-notes-main', '#details-id', 'attribute');
    displayDetails();

    initializeDatatable({
        selector: '#attribute-value-table',
        ajaxUrl: './app/Controllers/AttributeController.php',
        transaction: 'generate attribute value table',
        ajaxData: {
            attribute_id: attribute_id,
            page_id: page_id
        },
        columns: [
            { data: 'ATTRIBUTE_VALUE' },
            { data: 'ACTION' }
        ],
        columnDefs: [
            { width: 'auto', targets: 0, responsivePriority: 1 },
            { width: 'auto', bSortable: false, targets: 1, responsivePriority: 2 }
        ],
        order : [[0, 'asc']]
    });
    
        initializeDatatableControls('#attribute-value-table');

    $('#attribute_form').validate({
        rules: {
            attribute_name: { required: true },
            variant_creation: { required: true },
            display_type: { required: true }
        },
        messages: {
            attribute_name: { required: 'Enter the display name' },
            variant_creation: { required: 'Choose the variant creation' },
            display_type: { required: 'Choose the display type' }
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

            const transaction = 'save attribute';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('attribute_id', attribute_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/AttributeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save attribute failed with status: ${response.status}`);
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

    $('#attribute_value_form').validate({
        rules: {
            attribute_value_name: { required: true }
        },
        messages: {
            attribute_value_name: { required: 'Enter the attribute value name' }
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

            const transaction = 'save attribute value';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('attribute_id', attribute_id);

            disableButton('submit-attribute-value');

            try {
                const response = await fetch('./app/Controllers/AttributeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save attribute value failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#attribute-value-table');
                    enableButton('submit-attribute-value');
                    $('#attribute_value_modal').modal('hide');
                    resetForm('attribute_value_form');
                }
                else if(data.invalid_session){
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else{
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit-attribute-value');
                }
            } catch (error) {
                enableButton('submit-attribute-value');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('#delete-attribute')){
            const transaction = 'delete attribute';

            const result = await Swal.fire({
                title: 'Confirm Attribute Deletion',
                text: 'Are you sure you want to delete this attribute?',
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
                    formData.append('attribute_id', attribute_id);

                    const response = await fetch('./app/Controllers/AttributeController.php', {
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
        }

        if (event.target.closest('#add-attribute-value')){
            resetForm('attribute_value_form');
        }
        
        if (event.target.closest('.update-attribute-value')){
            const button                = event.target.closest('.update-attribute-value');
            const attribute_value_id    = button.dataset.attributeValueId;
        
            displayAttributeValueDetails(attribute_value_id);
        }
        
        if (event.target.closest('.view-attribute-value-log-notes')){
            const button                = event.target.closest('.view-attribute-value-log-notes');
            const attribute_value_id    = button.dataset.attributeValueId;
        
            attachLogNotesClassHandler('attribute_value', attribute_value_id);
        }
        
        if (event.target.closest('.delete-attribute-value')){
            const transaction           = 'delete attribute value';
            const button                = event.target.closest('.delete-attribute-value');
            const attribute_value_id    = button.dataset.attributeValueId;
        
            Swal.fire({
                title: 'Confirm Attribute Value Deletion',
                text: 'Are you sure you want to delete this attribute value?',
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
        
                const formData = new URLSearchParams();
                formData.append('transaction', transaction);
                formData.append('attribute_value_id', attribute_value_id);
        
                try {
                    const response = await fetch('./app/Controllers/AttributeController.php', {
                        method: 'POST',
                        body: formData
                    });
        
                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);
        
                    const data = await response.json();
        
                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        reloadDatatable('#attribute-value-table');
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