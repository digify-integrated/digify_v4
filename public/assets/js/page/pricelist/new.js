import { disableButton, enableButton, initializeDatePicker, generateDropdownOptions } from '../../utilities/form-utilities.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {    
    initializeDatePicker('#validity_start_date');
    initializeDatePicker('#validity_end_date');

    generateDropdownOptions({
        url: './app/Controllers/ProductController.php',
        dropdownSelector: '#product_id',
        data: { transaction: 'generate product options' }
    });

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

            const transaction   = 'save product pricelist';
            const page_link     = document.getElementById('page-link').getAttribute('href') || 'apps.php';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

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
                    setNotification(data.title, data.message, data.message_type);
                    window.location = `${page_link}&id=${data.product_pricelist_id}`;
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
});
