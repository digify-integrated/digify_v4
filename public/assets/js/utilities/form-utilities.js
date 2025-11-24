import { initializeDualListBoxIcon } from '../utilities/export.js';
import { handleSystemError } from '../modules/system-errors.js';

export const disableButton = (buttonIds) => {
  const ids = Array.isArray(buttonIds) ? buttonIds : [buttonIds];

  ids.forEach((id) => {
    const btn = document.getElementById(id);
    if (!btn) {
      console.warn(`disableButton: button with ID "${id}" not found`);
      return;
    }

    if (!btn.dataset.originalText) btn.dataset.originalText = btn.innerHTML;

    btn.disabled = true;
    btn.innerHTML = `<span><span class="spinner-border spinner-border-sm align-middle ms-0"></span></span>`;
  });
};

export const enableButton = (buttonIds) => {
  const ids = Array.isArray(buttonIds) ? buttonIds : [buttonIds];

  ids.forEach((id) => {
    const btn = document.getElementById(id);
    if (!btn) {
      console.warn(`enableButton: button with ID "${id}" not found`);
      return;
    }

    btn.disabled = false;
    if (btn.dataset.originalText) {
      btn.innerHTML = btn.dataset.originalText;
      delete btn.dataset.originalText;
    }
  });
};

export const resetForm = (formId) => {
  const form = document.getElementById(formId);
  if (!form) return;

  $(form).find('.form-select').val('').trigger('change');

  form.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));

  form.reset();

  form.querySelectorAll('input[type="hidden"]').forEach(hidden => {
    if (hidden.name !== 'csrf_token') {
      hidden.value = '';
    }
  });
};

export const generateDropdownOptions = async ({
  url,
  dropdownSelector,
  data = {},
  validateOnChange = false
}) => {
  try {
    const formData = new URLSearchParams();
    for (const key in data) {
      if (Object.prototype.hasOwnProperty.call(data, key)) {
        formData.append(key, data[key]);
      }
    }

    const response = await fetch(url, {
      method: 'POST',
      body: formData
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch dropdown data. HTTP status: ${response.status}`);
    }

    const result = await response.json();
    const $dropdown = $(dropdownSelector);

    if ($dropdown.hasClass('select2-hidden-accessible')) {
      $dropdown.select2('destroy');
    }

    $dropdown.empty();

    const $modalParent      = $dropdown.closest('.modal');
    const $offcanvasParent  = $dropdown.closest('.offcanvas');
    const $menuParent       = $dropdown.closest('[data-kt-menu="true"]');

    let dropdownParent = $(document.body);
    if ($modalParent.length) {
      dropdownParent = $modalParent;
    } else if ($offcanvasParent.length) {
      dropdownParent = $offcanvasParent;
    } else if ($menuParent.length) {
      dropdownParent = $menuParent;
    }

    $dropdown.select2({
      data: result,
      dropdownParent,
      width: '100%'
    })
    .on('select2:open', function () {
      focusSelect2Search();
    })
    .on('select2:unselect select2:clear', function () {
      const $this = $(this);
      setTimeout(() => $this.select2('close'), 0);
    });

    $(document)
      .off('mousedown.select2-remove-close')
      .on('mousedown.select2-remove-close', '.select2-selection__choice__remove', function (e) {
        const $container  = $(this).closest('.select2');
        const $select     = $container.prevAll('select').first();

        if ($select.length && $select.data('select2')) {
          e.stopPropagation();
          setTimeout(() => $select.select2('close'), 0);
        }
      });

    if (validateOnChange) {
      $dropdown.on('change', function () {
        $(this).valid();
      });
    }

  } catch (error) {
    handleSystemError(error, 'fetch_failed', `Dropdown generation failed: ${error.message}`);
  }
};

function focusSelect2Search() {
  setTimeout(() => {
    const searchField = document.querySelector('.select2-container--open .select2-search__field');
    if (searchField) {
      searchField.focus();
    }
  }, 100);
}

export const generateDualListBox = async ({ url, selectSelector, data = {} }) => {
  try {
    const formData = new URLSearchParams();
    for (const key in data) {
      if (Object.prototype.hasOwnProperty.call(data, key)) {
        formData.append(key, data[key]);
      }
    }

    const response = await fetch(url, {
      method: 'POST',
      body: formData
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch dual list box data. HTTP status: ${response.status}`);
    }

    const result = await response.json();

    const select = document.getElementById(selectSelector);
    if (!select) {
      return;
    }

    select.options.length = 0;
    result.forEach(opt => {
      const option = new Option(opt.text, opt.id);
      select.appendChild(option);
    });

    if ($(`#${selectSelector}`).length) {
      $(`#${selectSelector}`).bootstrapDualListbox({
        nonSelectedListLabel: 'Non-selected',
        selectedListLabel: 'Selected',
        preserveSelectionOnMove: 'moved',
        moveOnSelect: false,
        helperSelectNamePostfix: false
      });

      $(`#${selectSelector}`).bootstrapDualListbox('refresh', true);
      initializeDualListBoxIcon();
    }
  } catch (error) {
    handleSystemError(error, 'fetch_failed', `Dual list box generation failed: ${error.message}`);
  }
};

export const initializeTinyMCE = (tiny_mce_id, disabled = 0) => {
    let options = {
        selector: tiny_mce_id,
        height : "350",
        toolbar: [
            'styleselect fontselect fontsizeselect',
            'undo redo | cut copy paste | bold italic | link image | alignleft aligncenter alignright alignjustify',
            'bullist numlist | outdent indent | blockquote subscript superscript | advlist | autolink | lists charmap | preview |  code | table tabledelete | tableprops tablerowprops tablecellprops | tableinsertrowbefore tableinsertrowafter tabledeleterow | tableinsertcolbefore tableinsertcolafter tabledeletecol'
        ],
        plugins: 'advlist autolink link image lists charmap preview table code',
        license_key: 'gpl'
    };

    if (KTThemeMode.getMode() === "dark") {
        options["skin"] = "oxide-dark";
        options["content_css"] = "dark";
    }

    tinymce.init(options);

    if(disabled){
        tinymce.activeEditor.mode.set('readonly');
    }
}

export const initializeDatePicker = (selector, enableTime = false, dateFormat = "M d, Y") => {
  $(selector).flatpickr({
    enableTime: enableTime,
    dateFormat: dateFormat
  });
}

export const initializeDateRangePicker = (
  selector,
  {
    startDate = moment().startOf("day"),
    endDate = moment().endOf("day"),
    ranges = {
      "Today": [moment(), moment()],
      "Yesterday": [
        moment().subtract(1, "days"),
        moment().subtract(1, "days")
      ],
      "Last 7 Days": [moment().subtract(6, "days"), moment()],
      "Last 30 Days": [moment().subtract(29, "days"), moment()],
      "This Month": [
        moment().startOf("month"),
        moment().endOf("month")
      ],
      "Last Month": [
        moment().subtract(1, "month").startOf("month"),
        moment().subtract(1, "month").endOf("month")
      ]
    },
    callback = null
  } = {}
) => {

  const cb = (start, end) => {
    if (typeof callback === "function") {
      callback(start, end);
    }
  };

  $(selector).daterangepicker(
    {
      startDate,
      endDate,
      ranges
    },
    cb
  );

  cb(startDate, endDate);
};
