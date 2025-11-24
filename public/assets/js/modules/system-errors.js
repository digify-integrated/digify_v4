import { showErrorDialog } from './notifications.js';

export const handleSystemError = async (xhr, status, error) => {
  let message = `
    <strong>Status:</strong> ${status}<br/>
    <strong>Error:</strong> ${error || 'Unknown error'}<br/>
  `;

  if (xhr instanceof Error) {
    message += `
      <strong>Error Name:</strong> ${xhr.name}<br/>
      <strong>Message:</strong> ${xhr.message}<br/>
      <strong>Stack Trace:</strong><pre>${xhr.stack || 'No stack trace available'}</pre>
    `;
  } 
  else if (xhr instanceof Response) {
    message += `
      <strong>HTTP Status:</strong> ${xhr.status} ${xhr.statusText}<br/>
      <strong>URL:</strong> ${xhr.url}<br/>
    `;
    try {
      const text = await xhr.text();
      message += `<strong>Response Body:</strong><pre>${text || 'No response body'}</pre>`;
    } catch {
      message += `<strong>Response Body:</strong> Could not be read`;
    }
  } 
  else {
    message += `
      <strong>Response:</strong> ${xhr?.responseText ?? 'No response text'}<br/>
      <strong>Status Code:</strong> ${xhr?.status ?? 'Unknown'}<br/>
    `;
  }

  showErrorDialog(message);
};