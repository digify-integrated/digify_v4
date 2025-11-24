import { setHereClassForMenu } from './modules/menu.js';
import { checkNotification } from './modules/notifications.js';
import { initializeEventHandlers } from './events/event-handlers.js';

document.addEventListener('DOMContentLoaded', () => {
    setHereClassForMenu('#kt_app_header_menu', '.menu-item');

    checkNotification();

    initializeEventHandlers();
});