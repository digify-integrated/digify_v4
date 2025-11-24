import { discardCreate } from '../modules/dialogs.js';
import { passwordAddOn } from '../modules/password.js';
import { copyToClipboard } from '../utilities/helpers.js';

export const initializeEventHandlers = () => {
    document.addEventListener('click', (event) => {
        const targetId = event.target.id;

        switch (targetId) {
            case 'discard-create': {
                const pageLink = document.getElementById('page-link')?.getAttribute('href') || 'apps.php';
                
                discardCreate(pageLink);
                break;
            }

            case 'copy-error-message': {
                copyToClipboard('error-dialog');
                break;
            }
        }
    });

    passwordAddOn();
};