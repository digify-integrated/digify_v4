import { disableButton, enableButton } from '../utilities/form-utilities.js';
import { handleSystemError } from '../modules/system-errors.js';
import { showNotification } from '../modules/notifications.js';

export const initializeDualListBoxIcon = () => {
    $('.moveall i').removeClass().addClass('ki-duotone ki-right');
    $('.removeall i').removeClass().addClass('ki-duotone ki-left');
    $('.move i').removeClass().addClass('ki-duotone ki-right');
    $('.remove i').removeClass().addClass('ki-duotone ki-left');

    $('.moveall, .removeall, .move, .remove')
        .removeClass('btn-default')
        .addClass('btn-primary');
};

export const initializeExportFeature = (tableName) => {
    let selectedColumnsOrder = [];

    $(document).off('click', '#export-data').on('click', '#export-data', function () {
        const transaction = 'generate export column option';

        $.ajax({
            url: './app/Controllers/ExportController.php',
            method: 'POST',
            dataType: 'json',
            data: { transaction, table_name: tableName },
            success: function (response) {
                const select = document.getElementById('table_column');

                if (!select) return;
                select.options.length = 0;

                response.forEach(opt => {
                    select.appendChild(new Option(opt.text, opt.id));
                });
            },
            error: function (xhr, status, error) {
                handleSystemError(xhr, status, error);
            },
            complete: function () {
                if (!$('#table_column').length) return;

                $('#table_column').bootstrapDualListbox({
                    nonSelectedListLabel: 'Non-selected',
                    selectedListLabel: 'Selected',
                    preserveSelectionOnMove: 'moved',
                    moveOnSelect: false,
                    helperSelectNamePostfix: false,
                    sortByInputOrder: true
                });

                $('#table_column').off('change').on('change', function () {
                    const selected = $('#table_column option:selected')
                        .map((_, opt) => $(opt).val())
                        .get();

                    selectedColumnsOrder = selected;
                });

                $('#table_column').bootstrapDualListbox('refresh', true);
                initializeDualListBoxIcon();
            }
        });
    });

    $(document).off('click', '#submit-export').on('click', '#submit-export', function () {
        const transaction   = 'export data';
        const exportTo      = $('input[name="export_to"]:checked').val();
        const tableColumn   = selectedColumnsOrder;
        const exportId      = [];

        $('.datatable-checkbox-children:checked').each((_, element) => {
            exportId.push(element.value);
        });

        if (exportId.length === 0) {
            showNotification('Export Data', 'Choose the data you want to export.', 'error');
            return;
        }

        if (tableColumn.length === 0) {
            showNotification('Export Data', 'Choose the columns you want to export.', 'error');
            return;
        }

        $.ajax({
            type: 'POST',
            url: './app/Controllers/ExportController.php',
            data: {
                transaction,
                export_id: exportId,
                export_to: exportTo,
                table_column: tableColumn,
                table_name: tableName
            },
            xhrFields: { responseType: 'blob' },
            beforeSend: function () {
                disableButton('submit-export');
            },
            success: function (response, status, xhr) {
                let filename = '';
                const disposition = xhr.getResponseHeader('Content-Disposition');

                if (disposition?.includes('attachment')) {
                    const matches = /filename="(.+)"/.exec(disposition);
                    if (matches?.[1]) filename = matches[1];
                }

                const blob = new Blob([response], { type: xhr.getResponseHeader('Content-Type') });
                const link = document.createElement('a');
                link.href = URL.createObjectURL(blob);
                link.download = filename || `export.${exportTo}`;
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
            },
            error: function (xhr, status, error) {
                handleSystemError(xhr, status, error);
            },
            complete: function () {
                enableButton('submit-export');
            }
        });
    });
};
