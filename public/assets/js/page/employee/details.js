import { disableButton, enableButton, generateDropdownOptions, resetForm, initializeDatePicker } from '../../utilities/form-utilities.js';
import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { attachLogNotesHandler, attachLogNotesClassHandler } from '../../utilities/log-notes.js';
import { handleSystemError } from '../../modules/system-errors.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    const page_link     = document.getElementById('page-link').getAttribute('href') || 'apps.php';
    const employee_id   = document.getElementById('details-id')?.textContent.trim() || '';
    const page_id       = document.getElementById('page-id')?.value || '';
    
    const displayDetails = async () => {
        const transaction = 'fetch employee details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                $('#first_name').val(data.firstName || '');
                $('#middle_name').val(data.middleName || '');
                $('#last_name').val(data.lastName || '');
                $('#suffix').val(data.suffix || '');
                $('#private_address').val(data.privateAddress || '');
                $('#nickname').val(data.nickname || '');
                $('#dependents').val(data.dependents || '');
                $('#home_work_distance').val(data.homeWorkDistance || '');
                $('#height').val(data.height || '');
                $('#weight').val(data.weight || '');

                $('#employee_name_summary').text(data.fullName || '--');
                $('#nickname_summary').text(data.nickname || '--');
                $('#private_address_summary').text(data.employeeAddress || '--');
                $('#home_work_distance_summary').text(`${data.homeWorkDistance || 0} km`);
                $('#civil_status_summary').text(data.civilStatusName || '--');
                $('#dependents_summary').text(data.dependents || 0);
                $('#religion_summary').text(data.religionName || '--');
                $('#blood_type_summary').text(data.bloodTypeName || '--');
                $('#height_summary').text(`${data.height || 0} cm`);
                $('#weight_summary').text(`${data.weight || 0} kg`);
                $('#badge_id_summary').text(data.badgeID || '--');
                $('#private_email_summary').text(data.privateEmail || '--');
                $('#private_phone_summary').text(data.privatePhone || '--');
                $('#private_telephone_summary').text(data.privateTelephone || '--');
                $('#nationality_summary').text(data.nationalityName || '--');
                $('#gender_summary').text(data.genderName || '--');
                $('#birthday_summary').text(data.birthday || '--');
                $('#place_of_birth_summary').text(data.placeOfBirth || '--');
                $('#departure_reason_summary').text(data.departureReasonName || '--');
                $('#detailed_departure_reason_summary').text(data.detailedDepartureReason || '--');
                $('#departure_date_summary').text(data.departureDate || '--');

                $('#company_summary').text(data.companyName || '--');
                $('#department_summary').text(data.departmentName || '--');
                $('#job_position_title_summary').text(data.jobPositionName || '--');
                $('#job_position_summary').text(data.jobPositionName || '--');
                $('#manager_summary').text(data.managerName || '--');
                $('#time_off_approver_summary').text(data.timeOffApproverName || '--');
                $('#employment_type_summary').text(data.employmentTypeName || '--');
                $('#employment_location_type_summary').text(data.employmentLocationTypeName || '--');
                $('#work_location_summary').text(data.workLocationName || '--');
                $('#on_board_date_summary').text(data.onBoardDate || '--');
                $('#work_email_summary').text(data.workEmail || '--');
                $('#work_phone_summary').text(data.workPhone || '--');
                $('#work_telephone_summary').text(data.workTelephone || '--');

                $('#private_address_city_id').val(data.privateAddressCityID || '').trigger('change');
                $('#civil_status_id').val(data.civilStatusID || '').trigger('change');
                $('#religion_id').val(data.religionID || '').trigger('change');
                $('#blood_type_id').val(data.bloodTypeID || '').trigger('change');

                document.querySelector('#employment_status_summary').innerHTML = data?.employmentStatus ?? '';
                
                document.getElementById('employee_image_thumbnail').style.backgroundImage = `url(${data.employeeImage})`;
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

    const displayEducationDetails = async (employee_education_id) => {
        const transaction = 'fetch employee education details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('employee_education_id', employee_education_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                $('#employee_education_id').val(employee_education_id);
                $('#school').val(data.school || '');
                $('#degree').val(data.degree || '');
                $('#field_of_study').val(data.fieldOfStudy || '');
                $('#activities_societies').val(data.activitiesSocieties || '');
                $('#education_description').val(data.educationDescription || '');

                $('#start_month').val(data.startMonth || '').trigger('change');
                $('#start_year').val(data.startYear || '').trigger('change');
                $('#end_month').val(data.endMonth || '').trigger('change');
                $('#end_year').val(data.endYear || '').trigger('change');
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

    const displayEmergencyContactDetails = async (employee_emergency_contact_id) => {
        const transaction = 'fetch employee emergency contact details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('employee_emergency_contact_id', employee_emergency_contact_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                $('#employee_emergency_contact_id').val(employee_emergency_contact_id);
                $('#emergency_contact_name').val(data.emergencyContactName || '');
                $('#emergency_contact_telephone').val(data.telephone || '');
                $('#emergency_contact_mobile').val(data.mobile || '');
                $('#emergency_contact_email').val(data.email || '');

                $('#relationship_id').val(data.relationshipId || '').trigger('change');
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

    const displayLicenseDetails = async (employee_license_id) => {
        const transaction = 'fetch employee license details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('employee_license_id', employee_license_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                $('#employee_license_id').val(employee_license_id);
                $('#licensed_profession').val(data.licensedProfession || '');
                $('#licensing_body').val(data.licensingBody || '');
                $('#license_number').val(data.licenseNumber || '');
                $('#issue_date').val(data.issueDate || '');
                $('#expiration_date').val(data.expirationDate || '');
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

    const displayExperienceDetails = async (employee_experience_id) => {
        const transaction = 'fetch employee experience details';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('employee_experience_id', employee_experience_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();

            if (data.success) {
                $('#employee_experience_id').val(employee_experience_id);
                $('#job_title').val(data.jobTitle || '');
                $('#company_name').val(data.companyName || '');
                $('#location').val(data.location || '');
                $('#job_description').val(data.jobDescription || '');

                $('#employee_experience_employment_type_id').val(data.employmentTypeId || '').trigger('change');
                $('#employee_experience_start_month').val(data.startMonth || '').trigger('change');
                $('#employee_experience_start_year').val(data.startYear || '').trigger('change');
                $('#employee_experience_end_month').val(data.endMonth || '').trigger('change');
                $('#employee_experience_end_year').val(data.endYear || '').trigger('change');
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

    (async () => {
        const dropdownConfigs = [
            { url: './app/Controllers/CityController.php', selector: '#private_address_city_id', transaction: 'generate city options' },
            { url: './app/Controllers/NationalityController.php', selector: '#nationality_id', transaction: 'generate nationality options' },
            { url: './app/Controllers/CivilStatusController.php', selector: '#civil_status_id', transaction: 'generate civil status options' },
            { url: './app/Controllers/ReligionController.php', selector: '#religion_id', transaction: 'generate religion options' },
            { url: './app/Controllers/BloodTypeController.php', selector: '#blood_type_id', transaction: 'generate blood type options' },
            { url: './app/Controllers/GenderController.php', selector: '#gender_id', transaction: 'generate gender options' },
            { url: './app/Controllers/CompanyController.php', selector: '#company_id', transaction: 'generate company options' },
            { url: './app/Controllers/DepartmentController.php', selector: '#department_id', transaction: 'generate department options' },
            { url: './app/Controllers/JobPositionController.php', selector: '#job_position_id', transaction: 'generate job position options' },
            { url: './app/Controllers/EmploymentTypeController.php', selector: '#employment_type_id', transaction: 'generate employment type options' },
            { url: './app/Controllers/EmploymentTypeController.php', selector: '#employee_experience_employment_type_id', transaction: 'generate employment type options' },
            { url: './app/Controllers/EmploymentLocationTypeController.php', selector: '#employment_location_type_id', transaction: 'generate employment location type options' },
            { url: './app/Controllers/WorkLocationController.php', selector: '#work_location_id', transaction: 'generate work location options' },
            { url: './app/Controllers/LanguageController.php', selector: '#language_id', transaction: 'generate language options' },
            { url: './app/Controllers/LanguageProficiencyController.php', selector: '#language_proficiency_id', transaction: 'generate language proficiency options' },
            { url: './app/Controllers/EmployeeController.php', selector: '#manager_id', transaction: 'generate employee options' },
            { url: './app/Controllers/EmployeeController.php', selector: '#time_off_approver_id', transaction: 'generate employee options' },
            { url: './app/Controllers/RelationshipController.php', selector: '#relationship_id', transaction: 'generate relationship options' },
            { url: './app/Controllers/EmployeeDocumentTypeController.php', selector: '#employee_document_type_id', transaction: 'generate employee document type options' },
            { url: './app/Controllers/DepartureReasonController.php', selector: '#departure_reason_id', transaction: 'generate departure reason options' }
        ];
        
        for (const cfg of dropdownConfigs) {
            await generateDropdownOptions({
                url: cfg.url,
                dropdownSelector: cfg.selector,
                data: { transaction: cfg.transaction }
            });
        }

        await displayDetails();
        await languageList();
        await educationList();
        await emergencyContactList();
        await licenseList();
        await experienceList();
    })();

    const languageList = async () => {
        const transaction = 'generate employee language list';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('page_id', page_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();
            
            document.getElementById('language_summary').innerHTML = data[0].LANGUAGE_LIST;

        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch role list: ${error.message}`);
        }
    }

    const educationList = async () => {
        const transaction = 'generate employee education list';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('page_id', page_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();
            
            document.getElementById('educational_background_summary').innerHTML = data[0].EDUCATION_LIST;

        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch role list: ${error.message}`);
        }
    }

    const emergencyContactList = async () => {
        const transaction = 'generate employee emergency contact list';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('page_id', page_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();
            
            document.getElementById('emergency_contact_summary').innerHTML = data[0].EMERGENCY_CONTACT_LIST;

        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch role list: ${error.message}`);
        }
    }

    const licenseList = async () => {
        const transaction = 'generate employee license list';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('page_id', page_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();
            
            document.getElementById('license_summary').innerHTML = data[0].LICENSE_LIST;

        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch role list: ${error.message}`);
        }
    }

    const experienceList = async () => {
        const transaction = 'generate employee experience list';

        try {
            const formData = new URLSearchParams();
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);
            formData.append('page_id', page_id);

            const response = await fetch('./app/Controllers/EmployeeController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) throw new Error(`Request failed with status ${response.status}`);

            const data = await response.json();
            
            document.getElementById('work_experience_summary').innerHTML = data[0].EXPERIENCE_LIST;

        } catch (error) {
            handleSystemError(error, 'fetch_failed', `Failed to fetch role list: ${error.message}`);
        }
    }

    const toggleSection = (section) => {
        $(`#${section}_button`).toggleClass('d-none');
        $(`#${section}`).toggleClass('d-none');
        $(`#${section}_edit`).toggleClass('d-none');

        const formName = section.replace(/^change_/, '');
        resetForm(`update_${formName}_form`);
    }

    initializeDatatable({
        selector: '#employee-document-table',
        ajaxUrl: './app/Controllers/EmployeeController.php',
        transaction: 'generate employee document table',
        ajaxData: {
            employee_id: employee_id
        },
        columns: [
            { data: 'DOCUMENT' },
            { data: 'SIZE' },
            { data: 'UPLOAD_DATE' },
            { data: 'ACTION' }
        ],
        columnDefs: [
            { width: 'auto', targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 },
            { width: 'auto', targets: 2, type: 'date', responsivePriority: 3 },
            { width: 'auto', targets: 3, responsivePriority: 4 }
        ],
        order : [[2, 'desc']]
    });

    attachLogNotesHandler('#log-notes-main', '#details-id', 'employee');
    initializeDatePicker('#birthday');
    initializeDatePicker('#on_board_date');
    initializeDatePicker('#issue_date');
    initializeDatePicker('#expiration_date');
    initializeDatePicker('#departure_date');
    initializeDatatableControls('#employee-document-table');

    $('#personal_details_form').validate({
        rules: {
            first_name: { required: true },
            last_name: { required: true },
            private_address: { required: true },
            private_address_city_id: { required: true },
            civil_status_id: { required: true }
        },
        messages: {
            first_name: { required: 'Enter the first name' },
            last_name: { required: 'Enter the last name' },
            private_address: { required: 'Enter the private address' },
            private_address_city_id: { required: 'Choose the private address city' },
            civil_status_id: { required: 'Choose the civil status' }
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

            const transaction = 'update employee personal details';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit-personal-details');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    displayDetails();
                    enableButton('submit-personal-details');
                    $('#update_personal_details_modal').modal('hide');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    enableButton('submit-personal-details');
                    showNotification(data.title, data.message, data.message_type);
                }
            } catch (error) {
                enableButton('submit-personal-details');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_pin_code_form').validate({
        rules: {
            pin_code: { required: true }
        },
        messages: {
            pin_code: { required: 'Enter the PIN code' }
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

            const transaction = 'update employee pin code';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_pin_code_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_pin_code');
                    displayDetails();
                    enableButton('update_pin_code_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_pin_code_submit');
                }
            } catch (error) {
                enableButton('update_pin_code_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_badge_id_form').validate({
        rules: {
            badge_id: { required: true }
        },
        messages: {
            badge_id: { required: 'Enter the badge ID' }
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

            const transaction = 'update employee badge id';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_badge_id_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_badge_id');
                    displayDetails();
                    enableButton('update_badge_id_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_badge_id_submit');
                }
            } catch (error) {
                enableButton('update_badge_id_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_private_email_form').validate({
        rules: {
            private_email: { required: true }
        },
        messages: {
            private_email: { required: 'Enter the private email' }
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

            const transaction = 'update employee private email';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_private_email_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_private_email');
                    displayDetails();
                    enableButton('update_private_email_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_private_email_submit');
                }
            } catch (error) {
                enableButton('update_private_email_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_private_phone_form').validate({
        rules: {
            private_phone: { required: true }
        },
        messages: {
            private_phone: { required: 'Enter the private phone' }
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

            const transaction = 'update employee private phone';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_private_phone_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_private_phone');
                    displayDetails();
                    enableButton('update_private_phone_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_private_phone_submit');
                }
            } catch (error) {
                enableButton('update_private_phone_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_private_telephone_form').validate({
        rules: {
            private_telephone: { required: true }
        },
        messages: {
            private_telephone: { required: 'Enter the private telephone' }
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

            const transaction = 'update employee private telephone';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_private_telephone_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_private_telephone');
                    displayDetails();
                    enableButton('update_private_telephone_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_private_telephone_submit');
                }
            } catch (error) {
                enableButton('update_private_telephone_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_nationality_form').validate({
        rules: {
            nationality_id: { required: true }
        },
        messages: {
            nationality_id: { required: 'Choose the nationality' }
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

            const transaction = 'update employee nationality';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_nationality_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_nationality');
                    displayDetails();
                    enableButton('update_nationality_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_nationality_submit');
                }
            } catch (error) {
                enableButton('update_nationality_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_gender_form').validate({
        rules: {
            gender_id: { required: true }
        },
        messages: {
            gender_id: { required: 'Choose the gender' }
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

            const transaction = 'update employee gender';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_gender_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_gender');
                    displayDetails();
                    enableButton('update_gender_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_gender_submit');
                }
            } catch (error) {
                enableButton('update_gender_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_birthday_form').validate({
        rules: {
            birthday: { required: true }
        },
        messages: {
            birthday: { required: 'Choose the date of birth' }
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

            const transaction = 'update employee birthday';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_birthday_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_birthday');
                    displayDetails();
                    enableButton('update_birthday_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_birthday_submit');
                }
            } catch (error) {
                enableButton('update_birthday_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_place_of_birth_form').validate({
        rules: {
            place_of_birth: { required: true }
        },
        messages: {
            place_of_birth: { required: 'Enter the place of birth' }
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

            const transaction = 'update employee place of birth';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_place_of_birth_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_place_of_birth');
                    displayDetails();
                    enableButton('update_place_of_birth_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_place_of_birth_submit');
                }
            } catch (error) {
                enableButton('update_place_of_birth_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_company_form').validate({
        rules: {
            company_id: { required: true }
        },
        messages: {
            company_id: { required: 'Choose the company' }
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

            const transaction = 'update employee company';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_company_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_company');
                    displayDetails();
                    enableButton('update_company_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_company_submit');
                }
            } catch (error) {
                enableButton('update_company_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_department_form').validate({
        rules: {
            department_id: { required: true }
        },
        messages: {
            department_id: { required: 'Choose the department' }
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

            const transaction = 'update employee department';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_department_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_department');
                    displayDetails();
                    enableButton('update_department_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_department_submit');
                }
            } catch (error) {
                enableButton('update_department_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_job_position_form').validate({
        rules: {
            job_position_id: { required: true }
        },
        messages: {
            job_position_id: { required: 'Choose the job position' }
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

            const transaction = 'update employee job position';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_job_position_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_job_position');
                    displayDetails();
                    enableButton('update_job_position_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_job_position_submit');
                }
            } catch (error) {
                enableButton('update_job_position_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_manager_form').validate({
        rules: {
            manager_id: { required: true }
        },
        messages: {
            manager_id: { required: 'Choose the manager' }
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

            const transaction = 'update employee manager';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_manager_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_manager');
                    displayDetails();
                    enableButton('update_manager_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_manager_submit');
                }
            } catch (error) {
                enableButton('update_manager_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_time_off_approver_form').validate({
        rules: {
            time_off_approver_id: { required: true }
        },
        messages: {
            time_off_approver_id: { required: 'Choose the time off approver' }
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

            const transaction = 'update employee time off approver';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_time_off_approver_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_time_off_approver');
                    displayDetails();
                    enableButton('update_time_off_approver_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_time_off_approver_submit');
                }
            } catch (error) {
                enableButton('update_time_off_approver_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_employment_type_form').validate({
        rules: {
            employment_type_id: { required: true }
        },
        messages: {
            employment_type_id: { required: 'Choose the employment type' }
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

            const transaction = 'update employee employment type';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_employment_type_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_employment_type');
                    displayDetails();
                    enableButton('update_employment_type_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_employment_type_submit');
                }
            } catch (error) {
                enableButton('update_employment_type_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_employment_location_type_form').validate({
        rules: {
            employment_location_type_id: { required: true }
        },
        messages: {
            employment_location_type_id: { required: 'Choose the employment location type' }
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

            const transaction = 'update employee employment location type';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_employment_location_type_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_employment_location_type');
                    displayDetails();
                    enableButton('update_employment_location_type_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_employment_location_type_submit');
                }
            } catch (error) {
                enableButton('update_employment_location_type_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_work_location_form').validate({
        rules: {
            work_location_id: { required: true }
        },
        messages: {
            work_location_id: { required: 'Choose the work location' }
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

            const transaction = 'update employee work location';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_work_location_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_work_location');
                    displayDetails();
                    enableButton('update_work_location_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_work_location_submit');
                }
            } catch (error) {
                enableButton('update_work_location_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_on_board_date_form').validate({
        rules: {
            on_board_date: { required: true }
        },
        messages: {
            on_board_date: { required: 'Choose the on board date' }
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

            const transaction = 'update employee on board date';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_on_board_date_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_on_board_date');
                    displayDetails();
                    enableButton('update_on_board_date_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_on_board_date_submit');
                }
            } catch (error) {
                enableButton('update_on_board_date_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_work_email_form').validate({
        rules: {
            work_email: { required: true }
        },
        messages: {
            work_email: { required: 'Enter the work email' }
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

            const transaction = 'update employee work email';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_work_email_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_work_email');
                    displayDetails();
                    enableButton('update_work_email_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_work_email_submit');
                }
            } catch (error) {
                enableButton('update_work_email_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_work_phone_form').validate({
        rules: {
            work_phone: { required: true }
        },
        messages: {
            work_phone: { required: 'Enter the work phone' }
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

            const transaction = 'update employee work phone';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_work_phone_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_work_phone');
                    displayDetails();
                    enableButton('update_work_phone_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_work_phone_submit');
                }
            } catch (error) {
                enableButton('update_work_phone_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#update_work_telephone_form').validate({
        rules: {
            work_telephone: { required: true }
        },
        messages: {
            work_telephone: { required: 'Enter the work telephone' }
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

            const transaction = 'update employee work telephone';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('update_work_telephone_submit');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    toggleSection('change_work_telephone');
                    displayDetails();
                    enableButton('update_work_telephone_submit');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('update_work_telephone_submit');
                }
            } catch (error) {
                enableButton('update_work_telephone_submit');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#employee_language_form').validate({
        rules: {
            language_id: { required: true },
            language_proficiency_id: { required: true }
        },
        messages: {
            language_id: { required: 'Choose the language' },
            language_proficiency_id: { required: 'Choose the language proficiency' }
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

            const transaction = 'save employee language';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit_employee_language');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    languageList();
                    $('#employee_language_modal').modal('hide');
                    enableButton('submit_employee_language');
                    resetForm('employee_language_form');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit_employee_language');
                }
            } catch (error) {
                enableButton('submit_employee_language');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#employee_education_form').validate({
        rules: {
            school: { required: true },
            start_month: { required: true },
            start_year: { required: true }
        },
        messages: {
            school: { required: 'Enter the school' },
            start_month: { required: 'Choose the start month' },
            start_year: { required: 'Choose the start year' }
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

            const transaction = 'save employee education';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit_employee_education');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    educationList();
                    $('#employee_education_modal').modal('hide');
                    enableButton('submit_employee_education');
                    resetForm('employee_education_form');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit_employee_education');
                }
            } catch (error) {
                enableButton('submit_employee_education');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#employee_emergency_contact_form').validate({
        rules: {
            emergency_contact_name: { required: true },
            relationship_id: { required: true },
            emergency_contact_telephone: { contactEmergencyContactRequired: true },
            emergency_contact_mobile: { contactEmergencyContactRequired: true },
            emergency_contact_email: {
                contactEmergencyContactRequired: true,
                email: true
            }
        },
        messages: {
            emergency_contact_name: {
                required: 'Enter the emergency contact name'
            },
            relationship_id: {
                required: 'Choose the relationship'
            }
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

            const transaction = 'save employee emergency contact';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit_employee_emergency_contact');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    emergencyContactList();
                    $('#employee_emergency_contact_modal').modal('hide');
                    enableButton('submit_employee_emergency_contact');
                    resetForm('employee_emergency_contact_form');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit_employee_emergency_contact');
                }
            } catch (error) {
                enableButton('submit_employee_emergency_contact');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#employee_license_form').validate({
        rules: {
            licensed_profession: { required: true },
            licensing_body: { required: true },
            license_number: { required: true },
            issue_date: { required: true }
        },
        messages: {
            licensed_profession: { required: 'Enter the licensed profession' },
            licensing_body: { required: 'Enter the licensing body' },
            license_number: { required: 'Enter the license number' },
            issue_date: { required: 'Choose the issue date' }
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

            const transaction = 'save employee license';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit_employee_license');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    licenseList();
                    $('#employee_license_modal').modal('hide');
                    enableButton('submit_employee_license');
                    resetForm('employee_license_form');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit_employee_license');
                }
            } catch (error) {
                enableButton('submit_employee_license');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#employee_experience_form').validate({
        rules: {
            job_title: { required: true },
            company_name: { required: true },
            location: { required: true },
            employee_experience_employment_type_id: { required: true },
            employee_experience_start_month: { required: true },
            employee_experience_start_year: { required: true }
        },
        messages: {
            job_title: { required: 'Enter the job title' },
            company_name: { required: 'Enter the company name' },
            location: { required: 'Enter the location' },
            employee_experience_employment_type_id: { required: 'Choose the employment type' },
            employee_experience_start_month: { required: 'Choose the start month' },
            employee_experience_start_year: { required: 'Choose the start year' }
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

            const transaction = 'save employee experience';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit_employee_experience');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    experienceList();
                    $('#employee_experience_modal').modal('hide');
                    enableButton('submit_employee_experience');
                    resetForm('employee_experience_form');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit_employee_experience');
                }
            } catch (error) {
                enableButton('submit_employee_experience');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#employee_document_form').validate({
        rules: {
            document_name: { required: true },
            document_file: { required: true },
            employee_document_type_id: { required: true }
        },
        messages: {
            document_name: { required: 'Enter the document name' },
            document_file: { required: 'Choose the document file' },
            employee_document_type_id: { required: 'Choose the document type' }
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

            const transaction = 'insert employee document';

            const formData = new FormData(form);
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit_employee_document');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error(`Request failed with status: ${response.status}`);

                const data = await response.json();

                if (data.success) {
                    showNotification(data.title, data.message, data.message_type);
                    reloadDatatable('#employee-document-table');
                    $('#employee_document_modal').modal('hide');
                    enableButton('submit_employee_document');
                    resetForm('employee_document_form');
                }
                else if (data.invalid_session) {
                    setNotification(data.title, data.message, data.message_type);
                    window.location.href = data.redirect_link;
                }
                else {
                    showNotification(data.title, data.message, data.message_type);
                    enableButton('submit_employee_document');
                }
            } catch (error) {
                enableButton('submit_employee_document');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    $('#archive_employee_form').validate({
        rules: {
            departure_date: { required: true },
            departure_reason_id: { required: true },
            detailed_departure_reason: { required: true }
        },
        messages: {
            departure_date: { required: 'Choose the departure date' },
            departure_reason_id: { required: 'Choose the departure reason' },
            detailed_departure_reason: { required: 'Enter the detailed reason' }
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

            const transaction = 'update employee archive';

            const formData = new URLSearchParams(new FormData(form));
            formData.append('transaction', transaction);
            formData.append('employee_id', employee_id);

            disableButton('submit_employee_archive');

            try {
                const response = await fetch('./app/Controllers/EmployeeController.php', {
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
                    enableButton('submit_employee_archive');
                }
            } catch (error) {
                enableButton('submit_employee_archive');
                handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
            }

            return false;
        }
    });

    document.addEventListener('click', async (event) => {
        if (event.target.closest('[data-toggle-section]')){
            const section           = event.target.closest('[data-toggle-section]');
            const toggle_section    = section.dataset.toggleSection;
            toggleSection(toggle_section);
        }

        if (event.target.closest('#unarchive-employee')){
            const transaction = 'update employee unarchive';

            Swal.fire({
                title: 'Confirm Employee Unarchive',
                text: 'Are you sure you want to unarchive this employee?',
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
                formData.append('employee_id', employee_id);

                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
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

        if (event.target.closest('#delete-employee')){
            const transaction = 'delete employee';

            Swal.fire({
                title: 'Confirm Employee Deletion',
                text: 'Are you sure you want to delete this employee?',
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
                formData.append('employee_id', employee_id);
                
                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
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
                    handleSystemError(error, 'fetch_failed', `Fetch request failed: ${error.message}`);
                }
            });
        }

        if (event.target.closest('.view-employee-language-log-notes')){
            const button                = event.target.closest('.view-employee-language-log-notes');
            const employee_language_id  = button.dataset.employeeLanguageId;

            attachLogNotesClassHandler('employee_language', employee_language_id);
        }

        if (event.target.closest('.delete-employee-language')){
            const transaction           = 'delete employee language';
            const button                = event.target.closest('.delete-employee-language');
            const employee_language_id  = button.dataset.employeeLanguageId;

            Swal.fire({
                title: 'Confirm Employee Language Deletion',
                text: 'Are you sure you want to delete this employee language?',
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
                formData.append('employee_language_id', employee_language_id);

                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        languageList();
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

        if (event.target.closest('#add-employee-education')){
            resetForm('employee_education_form');
        }

        if (event.target.closest('.update-employee-education')){
            const button                    = event.target.closest('.update-employee-education');
            const employee_education_id     = button.dataset.employeeEducationId;

            displayEducationDetails(employee_education_id);
        }

        if (event.target.closest('.view-employee-education-log-notes')){
            const button                    = event.target.closest('.view-employee-education-log-notes');
            const employee_education_id     = button.dataset.employeeEducationId;

            attachLogNotesClassHandler('employee_education', employee_education_id);
        }

        if (event.target.closest('.delete-employee-education')){
            const transaction               = 'delete employee education';
            const button                    = event.target.closest('.delete-employee-education');
            const employee_education_id     = button.dataset.employeeEducationId;

            Swal.fire({
                title: 'Confirm Employee Educational Background Deletion',
                text: 'Are you sure you want to delete this employee educational background?',
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
                formData.append('employee_education_id', employee_education_id);

                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        educationList();
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

        if (event.target.closest('#add-employee-emergency-contact')){
            resetForm('employee_emergency_contact_form');
        }

        if (event.target.closest('.update-employee-emergency-contact')){
            const button                            = event.target.closest('.update-employee-emergency-contact');
            const employee_emergency_contact_id     = button.dataset.employeeEmergencyContactId;

            displayEmergencyContactDetails(employee_emergency_contact_id);
        }

        if (event.target.closest('.view-employee-emergency-contact-log-notes')){
            const button                            = event.target.closest('.view-employee-emergency-contact-log-notes');
            const employee_emergency_contact_id     = button.dataset.employeeEmergencyContactId;

            attachLogNotesClassHandler('employee_emergency_contact', employee_emergency_contact_id);
        }

        if (event.target.closest('.delete-employee-emergency-contact')){
            const transaction                       = 'delete employee emergency contact';
            const button                            = event.target.closest('.delete-employee-emergency-contact');
            const employee_emergency_contact_id     = button.dataset.employeeEmergencyContactId;

            Swal.fire({
                title: 'Confirm Employee Emergency Contact Deletion',
                text: 'Are you sure you want to delete this employee emergency contact?',
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
                formData.append('employee_emergency_contact_id', employee_emergency_contact_id);

                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        emergencyContactList();
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

        if (event.target.closest('#add-employee-license')){
            resetForm('employee_license_form');
        }

        if (event.target.closest('.update-employee-license')){
            const button                = event.target.closest('.update-employee-license');
            const employee_license_id   = button.dataset.employeeLicenseId;

            displayLicenseDetails(employee_license_id);
        }

        if (event.target.closest('.view-employee-license-log-notes')){
            const button                = event.target.closest('.view-employee-license-log-notes');
            const employee_license_id   = button.dataset.employeeLicenseId;

            attachLogNotesClassHandler('employee_license', employee_license_id);
        }

        if (event.target.closest('.delete-employee-license')){
            const transaction           = 'delete employee license';
            const button                = event.target.closest('.delete-employee-license');
            const employee_license_id   = button.dataset.employeeLicenseId;

            Swal.fire({
                title: 'Confirm Employee License Deletion',
                text: 'Are you sure you want to delete this employee license?',
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
                formData.append('employee_license_id', employee_license_id);

                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        licenseList();
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

        if (event.target.closest('#add-employee-experience')){
            resetForm('employee_experience_form');
        }

        if (event.target.closest('.update-employee-experience')){
            const button                    = event.target.closest('.update-employee-experience');
            const employee_experience_id    = button.dataset.employeeExperienceId;

            displayExperienceDetails(employee_experience_id);
        }

        if (event.target.closest('.view-employee-experience-log-notes')){
            const button                    = event.target.closest('.view-employee-experience-log-notes');
            const employee_experience_id    = button.dataset.employeeExperienceId;

            attachLogNotesClassHandler('employee_experience', employee_experience_id);
        }

        if (event.target.closest('.delete-employee-experience')){
            const transaction               = 'delete employee experience';
            const button                    = event.target.closest('.delete-employee-experience');
            const employee_experience_id    = button.dataset.employeeExperienceId;

            Swal.fire({
                title: 'Confirm Employee Experience Deletion',
                text: 'Are you sure you want to delete this employee experience?',
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
                formData.append('employee_experience_id', employee_experience_id);

                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        experienceList();
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

        if (event.target.closest('.view-employee-document-log-notes')){
            const button                = event.target.closest('.view-employee-document-log-notes');
            const employee_document_id  = button.dataset.employeeDocumentId;

            attachLogNotesClassHandler('employee_document', employee_document_id);
        }

        if (event.target.closest('.delete-employee-document')){
            const transaction           = 'delete employee document';
            const button                = event.target.closest('.delete-employee-document');
            const employee_document_id  = button.dataset.employeeDocumentId;

            Swal.fire({
                title: 'Confirm Employee Document Deletion',
                text: 'Are you sure you want to delete this employee document?',
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
                formData.append('employee_document_id', employee_document_id);

                try {
                    const response = await fetch('./app/Controllers/EmployeeController.php', {
                        method: 'POST',
                        body: formData
                    });

                    if (!response.ok) throw new Error(`Request failed: ${response.status}`);

                    const data = await response.json();

                    if (data.success) {
                        showNotification(data.title, data.message, data.message_type);
                        reloadDatatable('#employee-document-table');
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

    document.addEventListener('change', async (event) => {
        const input = event.target.closest('#employee_image');
        if (!input || !input.files.length) return;

        const transaction = 'update employee image';

        const formData = new FormData();
        formData.append('transaction', transaction);
        formData.append('employee_id', employee_id);
        formData.append('employee_image', input.files[0]);

        try {
            const response = await fetch('./app/Controllers/EmployeeController.php', {
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
    });
});