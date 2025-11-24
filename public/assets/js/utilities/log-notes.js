import { handleSystemError } from '../modules/system-errors.js';

export const attachLogNotesHandler = (triggerSelector, sourceSelector, type) => {
    $(document).on('click', triggerSelector, () => {
        const id = $(sourceSelector).text().trim();
        logNotes(type, id);
    });
};

export const attachLogNotesClassHandler = (sourceSelector, id) => {
    logNotes(sourceSelector, id);
};

export const logNotes = async (database_table, reference_id) => {
  const transaction = 'fetch log notes';

  try {
        const formData = new URLSearchParams();
        formData.append('transaction', transaction);
        formData.append('database_table', database_table);
        formData.append('reference_id', reference_id);

        const response = await fetch('./app/Controllers/LogNotesController.php', {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            throw new Error(`Failed to fetch log notes. HTTP status: ${response.status}`);
        }

        const data = await response.json();

        if (data.success) {
            const logNotesContainer = document.getElementById('log-notes');
            if (logNotesContainer) {
                logNotesContainer.innerHTML = data.log_notes;
            }
            else {
                console.warn('logNotes: #log-notes element not found, cannot display log notes.');
            }
        }
        else if (data.invalid_session) {
            setNotification(data.title, data.message, data.message_type);
            window.location.href = data.redirect_link;
        }
        else {
            showNotification(data.title, data.message, data.message_type);
        }
  } catch (error) {
    handleSystemError(error, 'fetch_failed', `Log notes fetch failed: ${error.message}`);
  }
};