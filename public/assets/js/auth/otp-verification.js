import { disableButton, enableButton } from '../utilities/form-utilities.js';
import { handleSystemError } from '../modules/system-errors.js';
import { showNotification, setNotification } from '../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const startCountdown = (duration) => {
        const $countdown    = $('#countdown');
        const $resendLink   = $('#resend-link');
        let remaining       = duration;

        $countdown.removeClass('d-none').text(formatTime(remaining));
        $resendLink.addClass('d-none');

        const expireTime = Date.now() + duration * 1000;
        localStorage.setItem('otpExpireTime', expireTime);

        if (window.otpCountdownTimer) {
            clearInterval(window.otpCountdownTimer);
        }

        window.otpCountdownTimer = setInterval(() => {
            remaining--;

            if (remaining >= 0) {
                $countdown.text(formatTime(remaining));
            } else {
                clearInterval(window.otpCountdownTimer);
                $countdown.addClass('d-none');
                $resendLink.removeClass('d-none');
                localStorage.removeItem('otpExpireTime'); // cleanup
            }
        }, 1000);
    }

    const resendOTP = async (countdownValue) => {
        const userAccountInput = document.getElementById('user_account_id');
        if (!userAccountInput) {
            console.warn('User account input not found.');
            return;
        }

        const user_account_id   = userAccountInput.value;
        const transaction       = 'resend otp';

        const formData = new URLSearchParams();
        formData.append('user_account_id', user_account_id);
        formData.append('transaction', transaction);

        const countdownEl   = document.getElementById('countdown');
        const resendLink    = document.getElementById('resend-link');

        if (countdownEl) countdownEl.classList.remove('d-none');
        if (resendLink) resendLink.classList.add('d-none');

        if (countdownEl) countdownEl.innerHTML = formatTime(countdownValue);
        startCountdown(countdownValue);

        try {
            const response = await fetch('./app/Controllers/AuthenticationController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Request failed with status ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
            } else {
                setNotification(data.title, data.message, data.message_type);
                window.location.href = 'index.php';
            }
        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
        }
    };

    const formatTime = (seconds) => {
        const minutes = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return `${minutes}:${secs < 10 ? '0' : ''}${secs}`;
    }

    $('#otp_form').validate({
        rules: {
            otp_code_1: { required: true },
            otp_code_2: { required: true },
            otp_code_3: { required: true },
            otp_code_4: { required: true },
            otp_code_5: { required: true },
            otp_code_6: { required: true }
        },
        messages: {
            otp_code_1: { required: 'Enter the security code' },
            otp_code_2: { required: 'Enter the security code' },
            otp_code_3: { required: 'Enter the security code' },
            otp_code_4: { required: 'Enter the security code' },
            otp_code_5: { required: 'Enter the security code' },
            otp_code_6: { required: 'Enter the security code' }
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

            const transaction = 'otp verification';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);

            disableButton('verify');
            
            try {
                const response = await fetch('./app/Controllers/AuthenticationController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) {
                    throw new Error(`OTP verification failed with status: ${response.status}`);
                }

                const data = await response.json();

                if (data.success) {
                    window.location.href = data.redirect_link;
                } else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('verify');
                }
            } catch (error) {
                enableButton('verify');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    const expireTime = localStorage.getItem('otpExpireTime');

    if (expireTime) {
        const remaining = Math.floor((expireTime - Date.now()) / 1000);
        if (remaining > 0) {
            startCountdown(remaining);
        } else {
            localStorage.removeItem('otpExpireTime');
        }
    }

    document.addEventListener('input', (event) => {
        const input = event.target.closest('.otp-input');
        if (!input) return;

        const maxLength         = parseInt(input.getAttribute('maxlength'), 10);
        const currentLength     = input.value.length;

        if (currentLength === maxLength) {
            const nextInput = input.nextElementSibling;
            if (nextInput?.classList.contains('otp-input')) {
                nextInput.focus();
            }
        }
    });

    document.addEventListener('paste', (event) => {
        const input = event.target.closest('.otp-input');
        if (!input) return;

        event.preventDefault();

        const pastedData    = event.clipboardData.getData('text/plain');
        const filteredData  = pastedData.replace(/[^a-zA-Z0-9]/g, '');

        filteredData.split('').forEach((char, index) => {
            const otpField = document.getElementById(`otp_code_${index + 1}`);
            if (otpField) {
                otpField.value = char;
            }
        });
    });

    document.addEventListener('keydown', (event) => {
        const input = event.target.closest('.otp-input');
        if (!input) return;

        if (event.key === 'Backspace' && input.value.length === 0) {
            const prevInput = input.previousElementSibling;
            if (prevInput?.classList.contains('otp-input')) {
                prevInput.focus();
            }
        }
    });

    document.addEventListener('click', (event) => {
        if (event.target.closest('#resend-link')) {
            resendOTP(180);
        }
    });
});