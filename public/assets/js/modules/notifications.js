export const showNotification = (title, message, type, timeOut = 2000) => {
  const validTypes = ['success', 'info', 'warning', 'error'];

  if (!validTypes.includes(type)) {
    console.error(`Invalid toastr type: ${type}`);
    return;
  }

  toastr.options = {
    closeButton: true,
    progressBar: true,
    preventDuplicates: true,
    positionClass: 'toastr-top-right',
    timeOut,
  };

  toastr[type](message, title);
};

export const showErrorDialog = (error) => {
  const errorDialogElement = document.getElementById('error-dialog');

  if (errorDialogElement) {
    errorDialogElement.innerHTML = error;
    $('#system-error-modal').modal('show');
  } else {
    console.error('Error dialog element not found.');
  }
};

export const setNotification = (title, message, type) => {
  sessionStorage.setItem('notificationTitle', title);
  sessionStorage.setItem('notificationMessage', message);
  sessionStorage.setItem('notificationType', type);
};

export const checkNotification = () => {
  const notificationTitle     = sessionStorage.getItem('notificationTitle');
  const notificationMessage   = sessionStorage.getItem('notificationMessage');
  const notificationType      = sessionStorage.getItem('notificationType');

  if (notificationTitle && notificationMessage && notificationType) {
    sessionStorage.removeItem('notificationTitle');
    sessionStorage.removeItem('notificationMessage');
    sessionStorage.removeItem('notificationType');

    showNotification(notificationTitle, notificationMessage, notificationType);
  }
};