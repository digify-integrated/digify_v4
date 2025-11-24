export const discardCreate = (pageLink) => {
  Swal.fire({
    title: 'Are you sure?',
    text: 'You will lose all unsaved changes!',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Yes, discard it!',
    cancelButtonText: 'Cancel',
    customClass: {
      confirmButton: 'btn btn-danger mt-2',
      cancelButton: 'btn btn-secondary ms-2 mt-2'
    },
    buttonsStyling: false,
  }).then(({ isConfirmed }) => {
    if (isConfirmed) {
      window.location.href = pageLink;
    }
  });
};