import { initializeDatatable, initializeDatatableControls, reloadDatatable } from '../../utilities/datatable.js';
import { initializeExportFeature } from '../../utilities/export.js';
import { showNotification, setNotification } from '../../modules/notifications.js';

document.addEventListener('DOMContentLoaded', () => {
    initializeDatatable({
        selector: '#language-proficiency-table',
        ajaxUrl: './app/Controllers/LanguageProficiencyController.php',
        transaction: 'generate language proficiency table',
        columns: [
            { data: 'CHECK_BOX' },
            { data: 'LANGUAGE_PROFICIENCY_NAME' }
        ],
        columnDefs: [
            { width: '5%', bSortable: false, targets: 0, responsivePriority: 1 },
            { width: 'auto', targets: 1, responsivePriority: 2 }
        ],
        onRowClick: (rowData) => {
            if (rowData?.LINK) window.open(rowData.LINK, '_blank');
        }
    });
    
    initializeDatatableControls('#language-proficiency-table');
    initializeExportFeature('language_proficiency');

    document.addEventListener('click', async (event) => {
        if (!event.target.closest('#delete-language-proficiency')) return;

        const transaction               = 'delete multiple language proficiency';
        const language_proficiency_id   = Array.from(document.querySelectorAll('.datatable-checkbox-children'))
                                                .filter(el => el.checked)
                                                .map(el => el.value);

        if (language_proficiency_id.length === 0) {
            showNotification('Deletion Multiple Language Proficiencies Error', 'Please select the language proficiencies you wish to delete.', 'error');
            return;
        }

        const result = await Swal.fire({
            title: 'Confirm Multiple Language Proficiencies Deletion',
            text: 'Are you sure you want to delete these language proficiencies?',
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
            language_proficiency_id.forEach(id => formData.append('language_proficiency_id[]', id));

            const response = await fetch('./app/Controllers/LanguageProficiencyController.php', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Deletion failed with status: ${response.status}`);
            }

            const data = await response.json();

            if (data.success) {
                showNotification(data.title, data.message, data.message_type);
                reloadDatatable('#language-proficiency-table');
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