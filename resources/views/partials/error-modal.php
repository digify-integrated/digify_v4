<div id="system-error-modal" class="modal fade" tabindex="-1" aria-labelledby="system-error-modal-label" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">System Error</h3>
                <div class="btn btn-icon btn-sm btn-active-light-primary ms-2" data-bs-dismiss="modal" aria-label="Close">
                    <i class="ki-duotone ki-cross fs-1"><span class="path1"></span><span class="path2"></span></i>
                </div>
            </div>

            <div class="modal-body">
                <div class="row align-items-center mb-3">
                    <div class="col">
                        <h5>An error occured</h5>
                        <p>Please use the copy button to report the error to your support service.</p>
                    </div>
                    <div class="col-auto">
                        <button type="button" class="btn btn-danger" id="copy-error-message">Copy the full error to clipboard</button>
                    </div>
                </div>
                <div class="row align-items-center mb-3">
                    <div class="col">
                        <div class="alert alert-danger text-danger" role="alert" id="error-dialog"></div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>