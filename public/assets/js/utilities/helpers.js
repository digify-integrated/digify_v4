import { showNotification } from '../modules/notifications.js';

export const copyToClipboard = (elementID) => {
  const text = document.getElementById(elementID)?.textContent?.trim() || '';

  if (!text) {
    showNotification('Copy Error', 'No text to copy', 'error');
    return;
  }

  navigator.clipboard.writeText(text)
    .then(() => showNotification('Success', 'Copied to clipboard', 'success'))
    .catch(() => showNotification('Error', 'Failed to copy', 'error'));
};
