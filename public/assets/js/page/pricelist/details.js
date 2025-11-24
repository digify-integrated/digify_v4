import { disableButton, enableButton, initializeDatePicker, generateDropdownOptions } from '../../utilities/form-utilities.js';
import { attachLogNotesHandler  } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    
    const page_link             = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
    const product_pricelist_id  = document.getElementById('details-id')?.textContent.trim();

    const displayDetails = async () => {
        const transaction = 'fetch product pricelist details';
    
        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('product_pricelist_id', product_pricelist_id);
    
            const response = await fetch('./app/Controllers/ProductController.php', {
                method: 'POST',
                body: formData
            });
    
            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);
    
            const data = await response.json();
    
            if (data.success) {
                $('#fixed_price').val(data.fixedPrice || 0);
                $('#min_quantity').val(data.minQuantity || 0);
                $('#validity_start_date').val(data.validityStartDate || '');
                $('#validity_end_date').val(data.validityEndDate || '');
                $('#remarks').val(data.remarks || '');

                $('#product_id').val(data.productId || '').trigger('change');
                $('#discount_type').val(data.discountType || 'Percentage').trigger('change');
            } 
            else if (data.notExist) {
                setNotification(data.title, data.message, data.message_type);
                window.location = page_link;
            } 
            else {
                showNotification(data.title, data.message, data.message_type);
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch product details: ${error.message}`);
        }
    };

    attachLogNotesHandler('#log-notes-main', '#details-id', 'product_pricelist');
    initializeDatePicker('#validity_start_date');
    initializeDatePicker('#validity_end_date');

    (async () => {
        await generateDropdownOptions({
            url: './app/Controllers/ProductController.php',
            dropdownSelector: '#product_id',
            data: { transaction: 'generate product options' }
        });

        await displayDetails();
    })();

    $('#product_pricelist_form').validate({
        rules: {
            product_id: { required: true },
            discount_type: { required: true },
            fixed_price: { required: true },
            min_quantity: { required: true },
            validity_start_date: { required: true }
        },
        messages: {
            product_id: { required: 'Choose the product' },
            discount_type: { required: 'Choose the discount type' },
            fixed_price: { required: 'Enter the fixed price' },
            min_quantity: { required: 'Enter the minimum quantity' },
            validity_start_date: { required: 'Choose the validity start date' }
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

            const transaction = 'save product pricelist';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('product_pricelist_id', product_pricelist_id);

            disableButton('submit-data');

            try {
                const response = await fetch('./app/Controllers/ProductController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`Save pricelist failed with status: ${response.status}`);
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
        if (!event.target.closest('#delete-product-pricelist')) return;

        const transaction = 'delete product pricelist';

        const result = await Swal.fire({
            title: 'Confirm Pricelist Deletion',
            text: 'Are you sure you want to delete this pricelist?',
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
                formData.append('product_pricelist_id', product_pricelist_id);

                const response = await fetch('./app/Controllers/ProductController.php', {
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