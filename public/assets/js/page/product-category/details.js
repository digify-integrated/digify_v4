import { disableButton, enableButton, resetForm, generateDropdownOptions } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link             = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const product_category_id   = document.getElementById('details-id')?.textContent.trim();

    const displayDetails = async () => {
        const transaction = 'fetch product category details';

        try {
            resetForm('product_category_form');
            
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('product_category_id', product_category_id);

            const response = await fetch('./app/Controllers/ProductCategoryController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                document.getElementById('product_category_name').value = data.productCategoryName || '';

                $('#parent_category_id').val(data.parentCategoryId || '').trigger('change');
                $('#costing_method').val(data.costingMethod || '').trigger('change');
                $('#display_order').val(data.displayOrder || '').trigger('change');
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
            url: './app/Controllers/ProductCategoryController.php',
            dropdownSelector: '#parent_category_id',
            data: { 
                transaction: 'generate parent category options', 
                product_category_id: product_category_id
            }
        });
    
        await displayDetails();
    })();

    attachLogNotesHandler('#log-notes-main', '#details-id', 'product_category');
    displayDetails();

    $('#product_category_form').validate({
        rules: {
            product_category_name: { required: true },
            costing_method: { required: true },
            display_order: { required: true }
        },
        messages: {
            product_category_name: { required: 'Enter the display name' },
            costing_method: { required: 'Choose the costing method' },
            display_order: { required: 'Enter the display order' }
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

            const transaction = 'save product category';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('product_category_id', product_category_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/ProductCategoryController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save product category failed with status: ${response.status}`);
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
        if (!event.target.closest('#delete-product-category')) return;

        const transaction = 'delete product category';

        const result = await Swal.fire({
            title: 'Confirm Product Category Deletion',
            text: 'Are you sure you want to delete this product category?',
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
                formData.append('product_category_id', product_category_id);

                const response = await fetch('./app/Controllers/ProductCategoryController.php', {
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