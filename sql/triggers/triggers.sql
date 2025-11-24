DELIMITER //

/* =============================================================================================
   TRIGGER: USER ACCOUNT
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_user_account_update//

CREATE TRIGGER trg_user_account_update
AFTER UPDATE ON user_account
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'User account changed.<br/><br/>'; -- Base message

    -- Compare fields (only those relevant for auditing)
    IF NEW.file_as <> OLD.file_as THEN
        SET audit_log = CONCAT(audit_log, "File As: ", OLD.file_as, " -> ", NEW.file_as, "<br/>");
    END IF;

    IF NEW.email <> OLD.email THEN
        SET audit_log = CONCAT(audit_log, "Email: ", OLD.email, " -> ", NEW.email, "<br/>");
    END IF;

    IF NEW.phone <> OLD.phone THEN
        SET audit_log = CONCAT(audit_log, "Phone: ", OLD.phone, " -> ", NEW.phone, "<br/>");
    END IF;

    IF NEW.active <> OLD.active THEN
        SET audit_log = CONCAT(audit_log, "Active: ", OLD.active, " -> ", NEW.active, "<br/>");
    END IF;

    IF NEW.two_factor_auth <> OLD.two_factor_auth THEN
        SET audit_log = CONCAT(audit_log, "2FA: ", OLD.two_factor_auth, " -> ", NEW.two_factor_auth, "<br/>");
    END IF;

    IF NEW.multiple_session <> OLD.multiple_session THEN
        SET audit_log = CONCAT(audit_log, "Multiple Session: ", OLD.multiple_session, " -> ", NEW.multiple_session, "<br/>");
    END IF;

    IF NEW.last_connection_date <> OLD.last_connection_date THEN
        SET audit_log = CONCAT(audit_log, "Last Connection: ", OLD.last_connection_date, " -> ", NEW.last_connection_date, "<br/>");
    END IF;

    IF NEW.last_failed_connection_date <> OLD.last_failed_connection_date THEN
        SET audit_log = CONCAT(audit_log, "Last Failed Connection: ", OLD.last_failed_connection_date, " -> ", NEW.last_failed_connection_date, "<br/>");
    END IF;

    IF NEW.last_password_change <> OLD.last_password_change THEN
        SET audit_log = CONCAT(audit_log, "Password Change: ", OLD.last_password_change, " -> ", NEW.last_password_change, "<br/>");
    END IF;

    IF NEW.last_password_reset_request <> OLD.last_password_reset_request THEN
        SET audit_log = CONCAT(audit_log, "Password Reset Request: ", OLD.last_password_reset_request, " -> ", NEW.last_password_reset_request, "<br/>");
    END IF;

    -- Insert only if something actually changed
    IF audit_log <> 'User account changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('user_account', NEW.user_account_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_user_account_insert//

CREATE TRIGGER trg_user_account_insert
AFTER INSERT ON user_account
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('user_account', NEW.user_account_id, 'User account created.', NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: NOTIFICATION SETTING
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_notification_setting_update//

CREATE TRIGGER trg_notification_setting_update
AFTER UPDATE ON notification_setting
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Notification setting changed.<br/><br/>';

    IF NEW.notification_setting_name <> OLD.notification_setting_name THEN
        SET audit_log = CONCAT(audit_log, "Notification Setting Name: ", OLD.notification_setting_name, " -> ", NEW.notification_setting_name, "<br/>");
    END IF;

    IF NEW.notification_setting_description <> OLD.notification_setting_description THEN
        SET audit_log = CONCAT(audit_log, "Notification Setting Description: ", OLD.notification_setting_description, " -> ", NEW.notification_setting_description, "<br/>");
    END IF;

    IF NEW.system_notification <> OLD.system_notification THEN
        SET audit_log = CONCAT(audit_log, "System Notification: ", OLD.system_notification, " -> ", NEW.system_notification, "<br/>");
    END IF;

    IF NEW.email_notification <> OLD.email_notification THEN
        SET audit_log = CONCAT(audit_log, "Notification Notification: ", OLD.email_notification, " -> ", NEW.email_notification, "<br/>");
    END IF;

    IF NEW.sms_notification <> OLD.sms_notification THEN
        SET audit_log = CONCAT(audit_log, "SMS Notification: ", OLD.sms_notification, " -> ", NEW.sms_notification, "<br/>");
    END IF;

    IF audit_log <> 'Notification setting changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('notification_setting', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

DROP TRIGGER IF EXISTS trg_notification_email_template_update//

CREATE TRIGGER trg_notification_email_template_update
AFTER UPDATE ON notification_setting_email_template
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Notification notification template changed.<br/><br/>';

    IF NEW.email_notification_subject <> OLD.email_notification_subject THEN
        SET audit_log = CONCAT(audit_log, "Notification Notification Subject: ", OLD.email_notification_subject, " -> ", NEW.email_notification_subject, "<br/>");
    END IF;

    IF NEW.email_notification_body <> OLD.email_notification_body THEN
        SET audit_log = CONCAT(audit_log, "Notification Notification Body: ", OLD.email_notification_body, " -> ", NEW.email_notification_body, "<br/>");
    END IF;

    IF audit_log <> 'Notification notification template changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('notification_setting_email_template', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

DROP TRIGGER IF EXISTS trg_notification_system_template_update//

CREATE TRIGGER trg_notification_system_template_update
AFTER UPDATE ON notification_setting_system_template
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'System notification template changed.<br/><br/>';

    IF NEW.system_notification_title <> OLD.system_notification_title THEN
        SET audit_log = CONCAT(audit_log, "System Notification Title: ", OLD.system_notification_title, " -> ", NEW.system_notification_title, "<br/>");
    END IF;

    IF NEW.system_notification_message <> OLD.system_notification_message THEN
        SET audit_log = CONCAT(audit_log, "System Notification Message: ", OLD.system_notification_message, " -> ", NEW.system_notification_message, "<br/>");
    END IF;

    IF audit_log <> 'System notification template changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('notification_setting_system_template', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

DROP TRIGGER IF EXISTS trg_notification_sms_template_update//

CREATE TRIGGER trg_notification_sms_template_update
AFTER UPDATE ON notification_setting_sms_template
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'SMS notification template changed.<br/><br/>';

    IF NEW.sms_notification_message <> OLD.sms_notification_message THEN
        SET audit_log = CONCAT(audit_log, "SMS Notification Message: ", OLD.sms_notification_message, " -> ", NEW.sms_notification_message, "<br/>");
    END IF;

    IF audit_log <> 'SMS notification template changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('notification_setting_sms_template', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_notification_setting_insert//

CREATE TRIGGER trg_notification_setting_insert
AFTER INSERT ON notification_setting
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Notification setting created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('notification_setting', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
END //

DROP TRIGGER IF EXISTS trg_notification_email_template_insert//

CREATE TRIGGER trg_notification_email_template_insert
AFTER INSERT ON notification_setting_email_template
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Notification notification template created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('notification_setting_email_template', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
END //

DROP TRIGGER IF EXISTS trg_notification_system_template_insert//

CREATE TRIGGER trg_notification_system_template_insert
AFTER INSERT ON notification_setting_system_template
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'System notification template created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('notification_setting_system_template', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
END //

DROP TRIGGER IF EXISTS trg_notification_sms_template_insert//

CREATE TRIGGER trg_notification_sms_template_insert
AFTER INSERT ON notification_setting_sms_template
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'SMS notification template created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('notification_setting_sms_template', NEW.notification_setting_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: APP MODULE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_app_module_update//

CREATE TRIGGER trg_app_module_update
AFTER UPDATE ON app_module
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'App module changed.<br/><br/>';

    IF NEW.app_module_name <> OLD.app_module_name THEN
        SET audit_log = CONCAT(audit_log, "App Module Name: ", OLD.app_module_name, " -> ", NEW.app_module_name, "<br/>");
    END IF;

    IF NEW.app_module_description <> OLD.app_module_description THEN
        SET audit_log = CONCAT(audit_log, "App Module Description: ", OLD.app_module_description, " -> ", NEW.app_module_description, "<br/>");
    END IF;

    IF NEW.menu_item_name <> OLD.menu_item_name THEN
        SET audit_log = CONCAT(audit_log, "Menu Item: ", OLD.menu_item_name, " -> ", NEW.menu_item_name, "<br/>");
    END IF;

    IF NEW.order_sequence <> OLD.order_sequence THEN
        SET audit_log = CONCAT(audit_log, "Order Sequence: ", OLD.order_sequence, " -> ", NEW.order_sequence, "<br/>");
    END IF;
    
    IF audit_log <> 'App module changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('app_module', NEW.app_module_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_app_module_insert//

CREATE TRIGGER trg_app_module_insert
AFTER INSERT ON app_module
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'App module created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('app_module', NEW.app_module_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: ROLE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_role_update//

CREATE TRIGGER trg_role_update
AFTER UPDATE ON role
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role changed.<br/><br/>';

    IF NEW.role_name <> OLD.role_name THEN
        SET audit_log = CONCAT(audit_log, "Role Name: ", OLD.role_name, " -> ", NEW.role_name, "<br/>");
    END IF;

    IF NEW.role_description <> OLD.role_description THEN
        SET audit_log = CONCAT(audit_log, "Role Description: ", OLD.role_description, " -> ", NEW.role_description, "<br/>");
    END IF;
    
    IF audit_log <> 'Role changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('role', NEW.role_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

DROP TRIGGER IF EXISTS trg_role_permission_update//

CREATE TRIGGER trg_role_permission_update
AFTER UPDATE ON role_permission
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role permission changed.<br/><br/>';

    IF NEW.role_name <> OLD.role_name THEN
        SET audit_log = CONCAT(audit_log, "Role Name: ", OLD.role_name, " -> ", NEW.role_name, "<br/>");
    END IF;

    IF NEW.menu_item_name <> OLD.menu_item_name THEN
        SET audit_log = CONCAT(audit_log, "Menu Item: ", OLD.menu_item_name, " -> ", NEW.menu_item_name, "<br/>");
    END IF;

    IF NEW.read_access <> OLD.read_access THEN
        SET audit_log = CONCAT(audit_log, "Read Access: ", OLD.read_access, " -> ", NEW.read_access, "<br/>");
    END IF;

    IF NEW.write_access <> OLD.write_access THEN
        SET audit_log = CONCAT(audit_log, "Write Access: ", OLD.write_access, " -> ", NEW.write_access, "<br/>");
    END IF;

    IF NEW.create_access <> OLD.create_access THEN
        SET audit_log = CONCAT(audit_log, "Create Access: ", OLD.create_access, " -> ", NEW.create_access, "<br/>");
    END IF;

    IF NEW.delete_access <> OLD.delete_access THEN
        SET audit_log = CONCAT(audit_log, "Delete Access: ", OLD.delete_access, " -> ", NEW.delete_access, "<br/>");
    END IF;

    IF NEW.import_access <> OLD.import_access THEN
        SET audit_log = CONCAT(audit_log, "Import Access: ", OLD.import_access, " -> ", NEW.import_access, "<br/>");
    END IF;

    IF NEW.export_access <> OLD.export_access THEN
        SET audit_log = CONCAT(audit_log, "Export Access: ", OLD.export_access, " -> ", NEW.export_access, "<br/>");
    END IF;

    IF NEW.log_notes_access <> OLD.log_notes_access THEN
        SET audit_log = CONCAT(audit_log, "Log Notes Access: ", OLD.log_notes_access, " -> ", NEW.log_notes_access, "<br/>");
    END IF;
    
    IF audit_log <> 'Role permission changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('role_permission', NEW.role_permission_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

DROP TRIGGER IF EXISTS trg_role_system_action_permission_update//

CREATE TRIGGER trg_role_system_action_permission_update
AFTER UPDATE ON role_system_action_permission
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role system action permission changed.<br/><br/>';

    IF NEW.role_name <> OLD.role_name THEN
        SET audit_log = CONCAT(audit_log, "Role Name: ", OLD.role_name, " -> ", NEW.role_name, "<br/>");
    END IF;

    IF NEW.system_action_name <> OLD.system_action_name THEN
        SET audit_log = CONCAT(audit_log, "System Action: ", OLD.system_action_name, " -> ", NEW.system_action_name, "<br/>");
    END IF;

    IF NEW.system_action_access <> OLD.system_action_access THEN
        SET audit_log = CONCAT(audit_log, "System Action Access: ", OLD.system_action_access, " -> ", NEW.system_action_access, "<br/>");
    END IF;
    
    IF audit_log <> 'Role system action permission changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('role_system_action_permission', NEW.role_system_action_permission_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

DROP TRIGGER IF EXISTS trg_role_user_account_update//

CREATE TRIGGER trg_role_user_account_update
AFTER UPDATE ON role_user_account
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role user account changed. <br/>';

    IF NEW.role_name <> OLD.role_name THEN
        SET audit_log = CONCAT(audit_log, "Role Name: ", OLD.role_name, " -> ", NEW.role_name, "<br/>");
    END IF;

    IF NEW.file_as <> OLD.file_as THEN
        SET audit_log = CONCAT(audit_log, "User Account Name: ", OLD.file_as, " -> ", NEW.file_as, "<br/>");
    END IF;
    
    IF audit_log <> 'Role user account changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('role_user_account', NEW.role_user_account_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_role_insert//

CREATE TRIGGER trg_role_insert
AFTER INSERT ON role
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('role', NEW.role_id, audit_log, NEW.last_log_by, NOW());
END //

DROP TRIGGER IF EXISTS trg_role_permission_insert//

CREATE TRIGGER trg_role_permission_insert
AFTER INSERT ON role_permission
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role permission created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('role_permission', NEW.role_permission_id, audit_log, NEW.last_log_by, NOW());
END //

DROP TRIGGER IF EXISTS trg_role_system_action_permission_insert//

CREATE TRIGGER trg_role_system_action_permission_insert
AFTER INSERT ON role_system_action_permission
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role system action permission created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('role_system_action_permission', NEW.role_system_action_permission_id, audit_log, NEW.last_log_by, NOW());
END //

DROP TRIGGER IF EXISTS trg_role_user_account_insert//

CREATE TRIGGER trg_role_user_account_insert
AFTER INSERT ON role_user_account
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Role user account created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('role_user_account', NEW.role_user_account_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: MENU ITEM
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_menu_item_update//

CREATE TRIGGER trg_menu_item_update
AFTER UPDATE ON menu_item
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Menu item changed.<br/><br/>';

    IF NEW.menu_item_name <> OLD.menu_item_name THEN
        SET audit_log = CONCAT(audit_log, "Menu Item Name: ", OLD.menu_item_name, " -> ", NEW.menu_item_name, "<br/>");
    END IF;

    IF NEW.menu_item_url <> OLD.menu_item_url THEN
        SET audit_log = CONCAT(audit_log, "Menu Item URL: ", OLD.menu_item_url, " -> ", NEW.menu_item_url, "<br/>");
    END IF;

    IF NEW.menu_item_icon <> OLD.menu_item_icon THEN
        SET audit_log = CONCAT(audit_log, "Menu Icon: ", OLD.menu_item_icon, " -> ", NEW.menu_item_icon, "<br/>");
    END IF;

    IF NEW.app_module_name <> OLD.app_module_name THEN
        SET audit_log = CONCAT(audit_log, "App Module: ", OLD.app_module_name, " -> ", NEW.app_module_name, "<br/>");
    END IF;

    IF NEW.parent_name <> OLD.parent_name THEN
        SET audit_log = CONCAT(audit_log, "Parent Menu: ", OLD.parent_name, " -> ", NEW.parent_name, "<br/>");
    END IF;

    IF NEW.order_sequence <> OLD.order_sequence THEN
        SET audit_log = CONCAT(audit_log, "Order Sequence: ", OLD.order_sequence, " -> ", NEW.order_sequence, "<br/>");
    END IF;

    IF NEW.table_name <> OLD.table_name THEN
        SET audit_log = CONCAT(audit_log, "Export Table: ", OLD.table_name, " -> ", NEW.table_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Menu item changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('menu_item', NEW.menu_item_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_menu_item_insert//

CREATE TRIGGER trg_menu_item_insert
AFTER INSERT ON menu_item
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Menu item created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('menu_item', NEW.menu_item_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: SYSTEM ACTION
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_system_action_update//

CREATE TRIGGER trg_system_action_update
AFTER UPDATE ON system_action
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'System action changed.<br/><br/>';

    IF NEW.system_action_name <> OLD.system_action_name THEN
        SET audit_log = CONCAT(audit_log, "System Action Name: ", OLD.system_action_name, " -> ", NEW.system_action_name, "<br/>");
    END IF;

    IF NEW.system_action_description <> OLD.system_action_description THEN
        SET audit_log = CONCAT(audit_log, "System Action Description: ", OLD.system_action_description, " -> ", NEW.system_action_description, "<br/>");
    END IF;
    
    IF audit_log <> 'System action changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('system_action', NEW.system_action_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_system_action_insert//

CREATE TRIGGER trg_system_action_insert
AFTER INSERT ON system_action
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'System action created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('system_action', NEW.system_action_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: FILE TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_file_type_update//

CREATE TRIGGER trg_file_type_update
AFTER UPDATE ON file_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'File type changed.<br/><br/>';

    IF NEW.file_type_name <> OLD.file_type_name THEN
        SET audit_log = CONCAT(audit_log, "File Type Name: ", OLD.file_type_name, " -> ", NEW.file_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'File type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('file_type', NEW.file_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_file_type_insert//

CREATE TRIGGER trg_file_type_insert
AFTER INSERT ON file_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'File type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('file_type', NEW.file_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: FILE EXTENSION
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_file_extension_update//

CREATE TRIGGER trg_file_extension_update
AFTER UPDATE ON file_extension
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'File extension changed.<br/><br/>';

    IF NEW.file_extension_name <> OLD.file_extension_name THEN
        SET audit_log = CONCAT(audit_log, "File Extension Name: ", OLD.file_extension_name, " -> ", NEW.file_extension_name, "<br/>");
    END IF;

    IF NEW.file_extension <> OLD.file_extension THEN
        SET audit_log = CONCAT(audit_log, "File Extension: ", OLD.file_extension, " -> ", NEW.file_extension, "<br/>");
    END IF;

    IF NEW.file_type_name <> OLD.file_type_name THEN
        SET audit_log = CONCAT(audit_log, "File Type: ", OLD.file_type_name, " -> ", NEW.file_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'File extension changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('file_extension', NEW.file_extension_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_file_extension_insert//

CREATE TRIGGER trg_file_extension_insert
AFTER INSERT ON file_extension
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'File extension created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('file_extension', NEW.file_extension_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: UPLOAD SETTING
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_upload_setting_update//

CREATE TRIGGER trg_upload_setting_update
AFTER UPDATE ON upload_setting
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Upload setting changed.<br/><br/>';

    IF NEW.upload_setting_name <> OLD.upload_setting_name THEN
        SET audit_log = CONCAT(audit_log, "Upload Setting Name: ", OLD.upload_setting_name, " -> ", NEW.upload_setting_name, "<br/>");
    END IF;

    IF NEW.upload_setting_description <> OLD.upload_setting_description THEN
        SET audit_log = CONCAT(audit_log, "Upload Setting Description: ", OLD.upload_setting_description, " -> ", NEW.upload_setting_description, "<br/>");
    END IF;

    IF NEW.max_file_size <> OLD.max_file_size THEN
        SET audit_log = CONCAT(audit_log, "Max File Size: ", OLD.max_file_size, " -> ", NEW.max_file_size, "<br/>");
    END IF;
    
    IF audit_log <> 'Upload setting changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('upload_setting', NEW.upload_setting_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //


/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_upload_setting_insert//

CREATE TRIGGER trg_upload_setting_insert
AFTER INSERT ON upload_setting
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Upload setting created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('upload_setting', NEW.upload_setting_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: UPLOAD SETTING FILE EXTENSION
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_upload_setting_file_update//

CREATE TRIGGER trg_upload_setting_file_update
AFTER UPDATE ON upload_setting_file_extension
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Upload setting file extension changed.<br/><br/>';

    IF NEW.upload_setting_name <> OLD.upload_setting_name THEN
        SET audit_log = CONCAT(audit_log, "Upload Setting Name: ", OLD.upload_setting_name, " -> ", NEW.upload_setting_name, "<br/>");
    END IF;

    IF NEW.file_extension_name <> OLD.file_extension_name THEN
        SET audit_log = CONCAT(audit_log, "File Extension Name: ", OLD.file_extension_name, " -> ", NEW.file_extension_name, "<br/>");
    END IF;

    IF NEW.file_extension <> OLD.file_extension THEN
        SET audit_log = CONCAT(audit_log, "File Extension: ", OLD.file_extension, " -> ", NEW.file_extension, "<br/>");
    END IF;
    
    IF audit_log <> 'Upload setting changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('upload_setting_file_extension', NEW.upload_setting_file_extension_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_upload_setting_file_insert//

CREATE TRIGGER trg_upload_setting_file_insert
AFTER INSERT ON upload_setting_file_extension
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Upload setting file extension created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('upload_setting_file_extension', NEW.upload_setting_file_extension_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: COUNTRY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_country_update//

CREATE TRIGGER trg_country_update
AFTER UPDATE ON country
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Country changed.<br/><br/>';

    IF NEW.country_name <> OLD.country_name THEN
        SET audit_log = CONCAT(audit_log, "Country Name: ", OLD.country_name, " -> ", NEW.country_name, "<br/>");
    END IF;

    IF NEW.country_code <> OLD.country_code THEN
        SET audit_log = CONCAT(audit_log, "Country Code: ", OLD.country_code, " -> ", NEW.country_code, "<br/>");
    END IF;

    IF NEW.phone_code <> OLD.phone_code THEN
        SET audit_log = CONCAT(audit_log, "Phone Code: ", OLD.phone_code, " -> ", NEW.phone_code, "<br/>");
    END IF;
    
    IF audit_log <> 'Country changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('country', NEW.country_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_country_insert//

CREATE TRIGGER trg_country_insert
AFTER INSERT ON country
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Country created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('country', NEW.country_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: STATE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_state_update//

CREATE TRIGGER trg_state_update
AFTER UPDATE ON state
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'State changed.<br/><br/>';

    IF NEW.state_name <> OLD.state_name THEN
        SET audit_log = CONCAT(audit_log, "State Name: ", OLD.state_name, " -> ", NEW.state_name, "<br/>");
    END IF;

    IF NEW.country_name <> OLD.country_name THEN
        SET audit_log = CONCAT(audit_log, "Country: ", OLD.country_name, " -> ", NEW.country_name, "<br/>");
    END IF;
    
    IF audit_log <> 'State changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('state', NEW.state_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_state_insert//

CREATE TRIGGER trg_state_insert
AFTER INSERT ON state
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'State created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('state', NEW.state_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: CITY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_city_update//

CREATE TRIGGER trg_city_update
AFTER UPDATE ON city
FOR EACH ROW
BEGIN
    DECLARE v_audit_log TEXT DEFAULT 'City changed.<br/><br/>';

    IF NEW.city_name <> OLD.city_name THEN
        SET v_audit_log = CONCAT(v_audit_log, 'City Name: ', OLD.city_name, ' -> ', NEW.city_name, '<br/>');
    END IF;

    IF NEW.state_name <> OLD.state_name THEN
        SET v_audit_log = CONCAT(v_audit_log, 'State: ', OLD.state_name, ' -> ', NEW.state_name, '<br/>');
    END IF;

    IF NEW.country_name <> OLD.country_name THEN
        SET v_audit_log = CONCAT(v_audit_log, 'Country: ', OLD.country_name, ' -> ', NEW.country_name, '<br/>');
    END IF;
    
    IF v_audit_log <> 'City changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('city', NEW.city_id, v_audit_log, NEW.last_log_by, NOW());
    END IF;
END //


/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_city_insert//

CREATE TRIGGER trg_city_insert
AFTER INSERT ON city
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'City created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('city', NEW.city_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: CURRENCY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_currency_update//

CREATE TRIGGER trg_currency_update
AFTER UPDATE ON currency
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Currency changed.<br/><br/>';

    IF NEW.currency_name <> OLD.currency_name THEN
        SET audit_log = CONCAT(audit_log, "Currency Name: ", OLD.currency_name, " -> ", NEW.currency_name, "<br/>");
    END IF;

    IF NEW.symbol <> OLD.symbol THEN
        SET audit_log = CONCAT(audit_log, "Symbol: ", OLD.symbol, " -> ", NEW.symbol, "<br/>");
    END IF;

    IF NEW.shorthand <> OLD.shorthand THEN
        SET audit_log = CONCAT(audit_log, "Shorthand: ", OLD.shorthand, " -> ", NEW.shorthand, "<br/>");
    END IF;
    
    IF audit_log <> 'Currency changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('currency', NEW.currency_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_currency_insert//

CREATE TRIGGER trg_currency_insert
AFTER INSERT ON currency
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Currency created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('currency', NEW.currency_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: NATIONALITY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_nationality_update//

CREATE TRIGGER trg_nationality_update
AFTER UPDATE ON nationality
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Nationality changed.<br/><br/>';

    IF NEW.nationality_name <> OLD.nationality_name THEN
        SET audit_log = CONCAT(audit_log, "Nationality Name: ", OLD.nationality_name, " -> ", NEW.nationality_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Nationality changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('nationality', NEW.nationality_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_nationality_insert//

CREATE TRIGGER trg_nationality_insert
AFTER INSERT ON nationality
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Nationality created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('nationality', NEW.nationality_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */


/* =============================================================================================
   TRIGGER: COMPANY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DELIMITER //

DROP TRIGGER IF EXISTS trg_company_update//

CREATE TRIGGER trg_company_update
AFTER UPDATE ON company
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Company changed.<br/><br/>';

    IF NEW.company_name <> OLD.company_name THEN
        SET audit_log = CONCAT(audit_log, "Company Name: ", OLD.company_name, " -> ", NEW.company_name, "<br/>");
    END IF;

    IF NEW.address <> OLD.address THEN
        SET audit_log = CONCAT(audit_log, "Address: ", OLD.address, " -> ", NEW.address, "<br/>");
    END IF;

    IF NEW.city_name <> OLD.city_name THEN
        SET audit_log = CONCAT(audit_log, "City: ", OLD.city_name, " -> ", NEW.city_name, "<br/>");
    END IF;

    IF NEW.state_name <> OLD.state_name THEN
        SET audit_log = CONCAT(audit_log, "State: ", OLD.state_name, " -> ", NEW.state_name, "<br/>");
    END IF;

    IF NEW.country_name <> OLD.country_name THEN
        SET audit_log = CONCAT(audit_log, "Country: ", OLD.country_name, " -> ", NEW.country_name, "<br/>");
    END IF;

    IF NEW.tax_id <> OLD.tax_id THEN
        SET audit_log = CONCAT(audit_log, "Tax ID: ", OLD.tax_id, " -> ", NEW.tax_id, "<br/>");
    END IF;

    IF NEW.currency_name <> OLD.currency_name THEN
        SET audit_log = CONCAT(audit_log, "Currency: ", OLD.currency_name, " -> ", NEW.currency_name, "<br/>");
    END IF;

    IF NEW.phone <> OLD.phone THEN
        SET audit_log = CONCAT(audit_log, "Phone: ", OLD.phone, " -> ", NEW.phone, "<br/>");
    END IF;

    IF NEW.telephone <> OLD.telephone THEN
        SET audit_log = CONCAT(audit_log, "Telephone: ", OLD.telephone, " -> ", NEW.telephone, "<br/>");
    END IF;

    IF NEW.email <> OLD.email THEN
        SET audit_log = CONCAT(audit_log, "Email: ", OLD.email, " -> ", NEW.email, "<br/>");
    END IF;

    IF NEW.website <> OLD.website THEN
        SET audit_log = CONCAT(audit_log, "Website: ", OLD.website, " -> ", NEW.website, "<br/>");
    END IF;
    
    IF audit_log <> 'Company changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('company', NEW.company_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_company_insert//

CREATE TRIGGER trg_company_insert
AFTER INSERT ON company
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Company created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('company', NEW.company_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: BLOOD TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_blood_type_update//

CREATE TRIGGER trg_blood_type_update
AFTER UPDATE ON blood_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Blood type changed.<br/><br/>';

    IF NEW.blood_type_name <> OLD.blood_type_name THEN
        SET audit_log = CONCAT(audit_log, "Blood Type Name: ", OLD.blood_type_name, " -> ", NEW.blood_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Blood type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('blood_type', NEW.blood_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_blood_type_insert//

CREATE TRIGGER trg_blood_type_insert
AFTER INSERT ON blood_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Blood type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('blood_type', NEW.blood_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: CIVIL STATUS
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_civil_status_update//

CREATE TRIGGER trg_civil_status_update
AFTER UPDATE ON civil_status
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Civil status changed.<br/><br/>';

    IF NEW.civil_status_name <> OLD.civil_status_name THEN
        SET audit_log = CONCAT(audit_log, "Civil Status Name: ", OLD.civil_status_name, " -> ", NEW.civil_status_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Civil status changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('civil_status', NEW.civil_status_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_civil_status_insert//

CREATE TRIGGER trg_civil_status_insert
AFTER INSERT ON civil_status
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Civil status created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('civil_status', NEW.civil_status_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: CREDENTIAL TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_credential_type_update//

CREATE TRIGGER trg_credential_type_update
AFTER UPDATE ON credential_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Credential type changed.<br/><br/>';

    IF NEW.credential_type_name <> OLD.credential_type_name THEN
        SET audit_log = CONCAT(audit_log, "Credential Type Name: ", OLD.credential_type_name, " -> ", NEW.credential_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Credential type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('credential_type', NEW.credential_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_credential_type_insert//

CREATE TRIGGER trg_credential_type_insert
AFTER INSERT ON credential_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Credential type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('credential_type', NEW.credential_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EDUCATIONAL STAGE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_educational_stage_update//

CREATE TRIGGER trg_educational_stage_update
AFTER UPDATE ON educational_stage
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Educational stage changed.<br/><br/>';

    IF NEW.educational_stage_name <> OLD.educational_stage_name THEN
        SET audit_log = CONCAT(audit_log, "Educational Stage Name: ", OLD.educational_stage_name, " -> ", NEW.educational_stage_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Educational stage changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('educational_stage', NEW.educational_stage_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_educational_stage_insert//

CREATE TRIGGER trg_educational_stage_insert
AFTER INSERT ON educational_stage
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Educational stage created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('educational_stage', NEW.educational_stage_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: GENDER
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_gender_update//

CREATE TRIGGER trg_gender_update
AFTER UPDATE ON gender
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Gender changed.<br/><br/>';

    IF NEW.gender_name <> OLD.gender_name THEN
        SET audit_log = CONCAT(audit_log, "Gender Name: ", OLD.gender_name, " -> ", NEW.gender_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Gender changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('gender', NEW.gender_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_gender_insert//

CREATE TRIGGER trg_gender_insert
AFTER INSERT ON gender
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Gender created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('gender', NEW.gender_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: RELATIONSHIP
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_relationship_update//

CREATE TRIGGER trg_relationship_update
AFTER UPDATE ON relationship
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Relationship changed.<br/><br/>';

    IF NEW.relationship_name <> OLD.relationship_name THEN
        SET audit_log = CONCAT(audit_log, "Relationship Name: ", OLD.relationship_name, " -> ", NEW.relationship_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Relationship changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('relationship', NEW.relationship_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_relationship_insert//

CREATE TRIGGER trg_relationship_insert
AFTER INSERT ON relationship
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Relationship created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('relationship', NEW.relationship_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: RELIGION
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_religion_update//

CREATE TRIGGER trg_religion_update
AFTER UPDATE ON religion
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Religion changed.<br/><br/>';

    IF NEW.religion_name <> OLD.religion_name THEN
        SET audit_log = CONCAT(audit_log, "Religion Name: ", OLD.religion_name, " -> ", NEW.religion_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Religion changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('religion', NEW.religion_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //


/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_religion_insert//

CREATE TRIGGER trg_religion_insert
AFTER INSERT ON religion
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Religion created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('religion', NEW.religion_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: LANGUAGE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_language_update//

CREATE TRIGGER trg_language_update
AFTER UPDATE ON language
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Language changed.<br/><br/>';

    IF NEW.language_name <> OLD.language_name THEN
        SET audit_log = CONCAT(audit_log, "Language Name: ", OLD.language_name, " -> ", NEW.language_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Language changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('language', NEW.language_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_language_insert//

CREATE TRIGGER trg_language_insert
AFTER INSERT ON language
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Language created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('language', NEW.language_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: LANGUAGE PROFICIENCY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_language_proficiency_update//

CREATE TRIGGER trg_language_proficiency_update
AFTER UPDATE ON language_proficiency
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Language proficiency changed.<br/><br/>';

    IF NEW.language_proficiency_name <> OLD.language_proficiency_name THEN
        SET audit_log = CONCAT(audit_log, "Language Proficiency Name: ", OLD.language_proficiency_name, " -> ", NEW.language_proficiency_name, "<br/>");
    END IF;

    IF NEW.language_proficiency_description <> OLD.language_proficiency_description THEN
        SET audit_log = CONCAT(audit_log, "Language Proficiency Description: ", OLD.language_proficiency_description, " -> ", NEW.language_proficiency_description, "<br/>");
    END IF;
    
    IF audit_log <> 'Language proficiency changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('language_proficiency', NEW.language_proficiency_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_language_proficiency_insert//

CREATE TRIGGER trg_language_proficiency_insert
AFTER INSERT ON language_proficiency
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Language proficiency created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('language_proficiency', NEW.language_proficiency_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: ADDRESS TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_address_type_update//

CREATE TRIGGER trg_address_type_update
AFTER UPDATE ON address_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Address type changed.<br/><br/>';

    IF NEW.address_type_name <> OLD.address_type_name THEN
        SET audit_log = CONCAT(audit_log, "Address Type Name: ", OLD.address_type_name, " -> ", NEW.address_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Address type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('address_type', NEW.address_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_address_type_insert//

CREATE TRIGGER trg_address_type_insert
AFTER INSERT ON address_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Address type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('address_type', NEW.address_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: CONTACT INFORMATION TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_contact_information_type_update//

CREATE TRIGGER trg_contact_information_type_update
AFTER UPDATE ON contact_information_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Contact information type changed.<br/><br/>';

    IF NEW.contact_information_type_name <> OLD.contact_information_type_name THEN
        SET audit_log = CONCAT(audit_log, "Contact Information Type Name: ", OLD.contact_information_type_name, " -> ", NEW.contact_information_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Contact information type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('contact_information_type', NEW.contact_information_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_contact_information_type_insert//

CREATE TRIGGER trg_contact_information_type_insert
AFTER INSERT ON contact_information_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Contact information type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('contact_information_type', NEW.contact_information_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: BANK
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_bank_update//

CREATE TRIGGER trg_bank_update
AFTER UPDATE ON bank
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Bank changed.<br/><br/>';

    IF NEW.bank_name <> OLD.bank_name THEN
        SET audit_log = CONCAT(audit_log, "Bank Name: ", OLD.bank_name, " -> ", NEW.bank_name, "<br/>");
    END IF;

    IF NEW.bank_identifier_code <> OLD.bank_identifier_code THEN
        SET audit_log = CONCAT(audit_log, "Bank Identifier Code: ", OLD.bank_identifier_code, " -> ", NEW.bank_identifier_code, "<br/>");
    END IF;
    
    IF audit_log <> 'Bank changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('bank', NEW.bank_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_bank_insert//

CREATE TRIGGER trg_bank_insert
AFTER INSERT ON bank
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Bank created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('bank', NEW.bank_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: BANK ACCOUNT TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_bank_account_type_update//

CREATE TRIGGER trg_bank_account_type_update
AFTER UPDATE ON bank_account_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Bank account type changed.<br/><br/>';

    IF NEW.bank_account_type_name <> OLD.bank_account_type_name THEN
        SET audit_log = CONCAT(audit_log, "Bank Account Type Name: ", OLD.bank_account_type_name, " -> ", NEW.bank_account_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Bank account type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('bank_account_type', NEW.bank_account_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_bank_account_type_insert//

CREATE TRIGGER trg_bank_account_type_insert
AFTER INSERT ON bank_account_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Bank account type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('bank_account_type', NEW.bank_account_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: DEPARTMENT
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */
DROP TRIGGER IF EXISTS trg_department_update//

CREATE TRIGGER trg_department_update
AFTER UPDATE ON department
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Department changed.<br/><br/>';

    IF NEW.department_name <> OLD.department_name THEN
        SET audit_log = CONCAT(audit_log, "Department Name: ", OLD.department_name, " -> ", NEW.department_name, "<br/>");
    END IF;

    IF NEW.parent_department_name <> OLD.parent_department_name THEN
        SET audit_log = CONCAT(audit_log, "Parent Department: ", OLD.parent_department_name, " -> ", NEW.parent_department_name, "<br/>");
    END IF;

    IF NEW.manager_name <> OLD.manager_name THEN
        SET audit_log = CONCAT(audit_log, "Manager: ", OLD.manager_name, " -> ", NEW.manager_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Department changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('department', NEW.department_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_department_insert//

CREATE TRIGGER trg_department_insert
AFTER INSERT ON department
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Department created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('department', NEW.department_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: DEPARTURE REASON
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_departure_reason_update//

CREATE TRIGGER trg_departure_reason_update
AFTER UPDATE ON departure_reason
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Departure reason changed.<br/><br/>';

    IF NEW.departure_reason_name <> OLD.departure_reason_name THEN
        SET audit_log = CONCAT(audit_log, "Departure Reason Name: ", OLD.departure_reason_name, " -> ", NEW.departure_reason_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Departure reason changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('departure_reason', NEW.departure_reason_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_departure_reason_insert//

CREATE TRIGGER trg_departure_reason_insert
AFTER INSERT ON departure_reason
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Departure reason created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('departure_reason', NEW.departure_reason_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYMENT LOCATION TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employment_location_type_update//

CREATE TRIGGER trg_employment_location_type_update
AFTER UPDATE ON employment_location_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employment location type changed.<br/><br/>';

    IF NEW.employment_location_type_name <> OLD.employment_location_type_name THEN
        SET audit_log = CONCAT(audit_log, "Employment Location Type Name: ", OLD.employment_location_type_name, " -> ", NEW.employment_location_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Employment location type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employment_location_type', NEW.employment_location_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employment_location_type_insert//

CREATE TRIGGER trg_employment_location_type_insert
AFTER INSERT ON employment_location_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employment location type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employment_location_type', NEW.employment_location_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYMENT TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employment_type_update//

CREATE TRIGGER trg_employment_type_update
AFTER UPDATE ON employment_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employment Type changed.<br/><br/>';

    IF NEW.employment_type_name <> OLD.employment_type_name THEN
        SET audit_log = CONCAT(audit_log, "Employment Type Name: ", OLD.employment_type_name, " -> ", NEW.employment_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Employment Type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employment_type', NEW.employment_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employment_type_insert//

CREATE TRIGGER trg_employment_type_insert
AFTER INSERT ON employment_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employment Type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employment_type', NEW.employment_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: JOB POSITION
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_job_position_update//

CREATE TRIGGER trg_job_position_update
AFTER UPDATE ON job_position
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Job position changed.<br/><br/>';

    IF NEW.job_position_name <> OLD.job_position_name THEN
        SET audit_log = CONCAT(audit_log, "Job Position Name: ", OLD.job_position_name, " -> ", NEW.job_position_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Job position changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('job_position', NEW.job_position_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_job_position_insert//

CREATE TRIGGER trg_job_position_insert
AFTER INSERT ON job_position
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Job position created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('job_position', NEW.job_position_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: WORK LOCATION
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_work_location_update//

CREATE TRIGGER trg_work_location_update
AFTER UPDATE ON work_location
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Work location changed.<br/><br/>';

    IF NEW.work_location_name <> OLD.work_location_name THEN
        SET audit_log = CONCAT(audit_log, "Work Location Name: ", OLD.work_location_name, " -> ", NEW.work_location_name, "<br/>");
    END IF;

    IF NEW.address <> OLD.address THEN
        SET audit_log = CONCAT(audit_log, "Address: ", OLD.address, " -> ", NEW.address, "<br/>");
    END IF;

    IF NEW.city_name <> OLD.city_name THEN
        SET audit_log = CONCAT(audit_log, "City: ", OLD.city_name, " -> ", NEW.city_name, "<br/>");
    END IF;

    IF NEW.state_name <> OLD.state_name THEN
        SET audit_log = CONCAT(audit_log, "State: ", OLD.state_name, " -> ", NEW.state_name, "<br/>");
    END IF;

    IF NEW.country_name <> OLD.country_name THEN
        SET audit_log = CONCAT(audit_log, "Country: ", OLD.country_name, " -> ", NEW.country_name, "<br/>");
    END IF;

    IF NEW.phone <> OLD.phone THEN
        SET audit_log = CONCAT(audit_log, "Phone: ", OLD.phone, " -> ", NEW.phone, "<br/>");
    END IF;

    IF NEW.telephone <> OLD.telephone THEN
        SET audit_log = CONCAT(audit_log, "Telephone: ", OLD.telephone, " -> ", NEW.telephone, "<br/>");
    END IF;

    IF NEW.email <> OLD.email THEN
        SET audit_log = CONCAT(audit_log, "Email: ", OLD.email, " -> ", NEW.email, "<br/>");
    END IF;
    
    IF audit_log <> 'Work location changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('work_location', NEW.work_location_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_work_location_insert//

CREATE TRIGGER trg_work_location_insert
AFTER INSERT ON work_location
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Work location created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('work_location', NEW.work_location_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_update//

CREATE TRIGGER trg_employee_update
AFTER UPDATE ON employee
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee changed.<br/><br/>';

    IF NEW.full_name <> OLD.full_name THEN
        SET audit_log = CONCAT(audit_log, "Full Name: ", OLD.full_name, " -> ", NEW.full_name, "<br/>");
    END IF;

    IF NEW.first_name <> OLD.first_name THEN
        SET audit_log = CONCAT(audit_log, "First Name: ", OLD.first_name, " -> ", NEW.first_name, "<br/>");
    END IF;

    IF NEW.middle_name <> OLD.middle_name THEN
        SET audit_log = CONCAT(audit_log, "Middle Name: ", OLD.middle_name, " -> ", NEW.middle_name, "<br/>");
    END IF;

    IF NEW.last_name <> OLD.last_name THEN
        SET audit_log = CONCAT(audit_log, "Last Name: ", OLD.last_name, " -> ", NEW.last_name, "<br/>");
    END IF;

    IF NEW.suffix <> OLD.suffix THEN
        SET audit_log = CONCAT(audit_log, "Suffix: ", OLD.suffix, " -> ", NEW.suffix, "<br/>");
    END IF;

    IF NEW.nickname <> OLD.nickname THEN
        SET audit_log = CONCAT(audit_log, "Nickname: ", OLD.nickname, " -> ", NEW.nickname, "<br/>");
    END IF;

    IF NEW.private_address <> OLD.private_address THEN
        SET audit_log = CONCAT(audit_log, "Private Address: ", OLD.private_address, " -> ", NEW.private_address, "<br/>");
    END IF;

    IF NEW.private_address_city_name <> OLD.private_address_city_name THEN
        SET audit_log = CONCAT(audit_log, "Private Address City: ", OLD.private_address_city_name, " -> ", NEW.private_address_city_name, "<br/>");
    END IF;

    IF NEW.private_address_state_name <> OLD.private_address_state_name THEN
        SET audit_log = CONCAT(audit_log, "Private Address State: ", OLD.private_address_state_name, " -> ", NEW.private_address_state_name, "<br/>");
    END IF;

    IF NEW.private_address_country_name <> OLD.private_address_country_name THEN
        SET audit_log = CONCAT(audit_log, "Private Address Country: ", OLD.private_address_country_name, " -> ", NEW.private_address_country_name, "<br/>");
    END IF;

    IF NEW.private_phone <> OLD.private_phone THEN
        SET audit_log = CONCAT(audit_log, "Private Phone: ", OLD.private_phone, " -> ", NEW.private_phone, "<br/>");
    END IF;

    IF NEW.private_telephone <> OLD.private_telephone THEN
        SET audit_log = CONCAT(audit_log, "Private Telephone: ", OLD.private_telephone, " -> ", NEW.private_telephone, "<br/>");
    END IF;

    IF NEW.private_email <> OLD.private_email THEN
        SET audit_log = CONCAT(audit_log, "Private Email: ", OLD.private_email, " -> ", NEW.private_email, "<br/>");
    END IF;

    IF NEW.civil_status_name <> OLD.civil_status_name THEN
        SET audit_log = CONCAT(audit_log, "Civil Status: ", OLD.civil_status_name, " -> ", NEW.civil_status_name, "<br/>");
    END IF;

    IF NEW.dependents <> OLD.dependents THEN
        SET audit_log = CONCAT(audit_log, "Dependents: ", OLD.dependents, " -> ", NEW.dependents, "<br/>");
    END IF;

    IF NEW.nationality_name <> OLD.nationality_name THEN
        SET audit_log = CONCAT(audit_log, "Nationality: ", OLD.nationality_name, " -> ", NEW.nationality_name, "<br/>");
    END IF;

    IF NEW.gender_name <> OLD.gender_name THEN
        SET audit_log = CONCAT(audit_log, "Gender: ", OLD.gender_name, " -> ", NEW.gender_name, "<br/>");
    END IF;

    IF NEW.religion_name <> OLD.religion_name THEN
        SET audit_log = CONCAT(audit_log, "Religion: ", OLD.religion_name, " -> ", NEW.religion_name, "<br/>");
    END IF;

    IF NEW.blood_type_name <> OLD.blood_type_name THEN
        SET audit_log = CONCAT(audit_log, "Blood Type: ", OLD.blood_type_name, " -> ", NEW.blood_type_name, "<br/>");
    END IF;

    IF NEW.birthday <> OLD.birthday THEN
        SET audit_log = CONCAT(audit_log, "Birthday: ", OLD.birthday, " -> ", NEW.birthday, "<br/>");
    END IF;

    IF NEW.place_of_birth <> OLD.place_of_birth THEN
        SET audit_log = CONCAT(audit_log, "Place of Birth: ", OLD.place_of_birth, " -> ", NEW.place_of_birth, "<br/>");
    END IF;

    IF NEW.home_work_distance <> OLD.home_work_distance THEN
        SET audit_log = CONCAT(audit_log, "Home-Work Distance: ", OLD.home_work_distance, " km -> ", NEW.home_work_distance, " km<br/>");
    END IF;

    IF NEW.height <> OLD.height THEN
        SET audit_log = CONCAT(audit_log, "Height: ", OLD.height, " cm -> ", NEW.height, " cm<br/>");
    END IF;

    IF NEW.weight <> OLD.weight THEN
        SET audit_log = CONCAT(audit_log, "Weight: ", OLD.weight, " kg -> ", NEW.weight, " kg<br/>");
    END IF;

    IF NEW.employment_status <> OLD.employment_status THEN
        SET audit_log = CONCAT(audit_log, "Employment Status: ", OLD.employment_status, " -> ", NEW.employment_status, "<br/>");
    END IF;

    IF NEW.company_name <> OLD.company_name THEN
        SET audit_log = CONCAT(audit_log, "Company: ", OLD.company_name, " -> ", NEW.company_name, "<br/>");
    END IF;

    IF NEW.department_name <> OLD.department_name THEN
        SET audit_log = CONCAT(audit_log, "Department: ", OLD.department_name, " -> ", NEW.department_name, "<br/>");
    END IF;

    IF NEW.job_position_name <> OLD.job_position_name THEN
        SET audit_log = CONCAT(audit_log, "Job Position: ", OLD.job_position_name, " -> ", NEW.job_position_name, "<br/>");
    END IF;

    IF NEW.work_phone <> OLD.work_phone THEN
        SET audit_log = CONCAT(audit_log, "Work Phone: ", OLD.work_phone, " -> ", NEW.work_phone, "<br/>");
    END IF;

    IF NEW.work_telephone <> OLD.work_telephone THEN
        SET audit_log = CONCAT(audit_log, "Work Telephone: ", OLD.work_telephone, " -> ", NEW.work_telephone, "<br/>");
    END IF;

    IF NEW.work_email <> OLD.work_email THEN
        SET audit_log = CONCAT(audit_log, "Work Email: ", OLD.work_email, " -> ", NEW.work_email, "<br/>");
    END IF;

    IF NEW.manager_name <> OLD.manager_name THEN
        SET audit_log = CONCAT(audit_log, "Manager: ", OLD.manager_name, " -> ", NEW.manager_name, "<br/>");
    END IF;

    IF NEW.work_location_name <> OLD.work_location_name THEN
        SET audit_log = CONCAT(audit_log, "Work Location: ", OLD.work_location_name, " -> ", NEW.work_location_name, "<br/>");
    END IF;

    IF NEW.employment_type_name <> OLD.employment_type_name THEN
        SET audit_log = CONCAT(audit_log, "Employment Type: ", OLD.employment_type_name, " -> ", NEW.employment_type_name, "<br/>");
    END IF;

    IF NEW.employment_location_type_name <> OLD.employment_location_type_name THEN
        SET audit_log = CONCAT(audit_log, "Employment Location Type: ", OLD.employment_location_type_name, " -> ", NEW.employment_location_type_name, "<br/>");
    END IF;

    IF NEW.badge_id <> OLD.badge_id THEN
        SET audit_log = CONCAT(audit_log, "Badge ID: ", OLD.badge_id, " -> ", NEW.badge_id, "<br/>");
    END IF;

    IF NEW.on_board_date <> OLD.on_board_date THEN
        SET audit_log = CONCAT(audit_log, "On-Board Date: ", OLD.on_board_date, " -> ", NEW.on_board_date, "<br/>");
    END IF;

    IF NEW.off_board_date <> OLD.off_board_date THEN
        SET audit_log = CONCAT(audit_log, "Off-Board Date: ", OLD.off_board_date, " -> ", NEW.off_board_date, "<br/>");
    END IF;

    IF NEW.time_off_approver_name <> OLD.time_off_approver_name THEN
        SET audit_log = CONCAT(audit_log, "Time-Off Approver: ", OLD.time_off_approver_name, " -> ", NEW.time_off_approver_name, "<br/>");
    END IF;

    IF NEW.departure_reason_name <> OLD.departure_reason_name THEN
        SET audit_log = CONCAT(audit_log, "Departure Reason: ", OLD.departure_reason_name, " -> ", NEW.departure_reason_name, "<br/>");
    END IF;

    IF NEW.detailed_departure_reason <> OLD.detailed_departure_reason THEN
        SET audit_log = CONCAT(audit_log, "Detailed Departure Reason: ", OLD.detailed_departure_reason, " -> ", NEW.detailed_departure_reason, "<br/>");
    END IF;

    IF NEW.departure_date <> OLD.departure_date THEN
        SET audit_log = CONCAT(audit_log, "Departure Date: ", OLD.departure_date, " -> ", NEW.departure_date, "<br/>");
    END IF;
    
    IF audit_log <> 'Employee changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employee', NEW.employee_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_insert//

CREATE TRIGGER trg_employee_insert
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee', NEW.employee_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE EXPERIENCE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_experience_update//

CREATE TRIGGER trg_employee_experience_update
AFTER UPDATE ON employee_experience
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee experience changed.<br/><br/>';

    IF NEW.job_title <> OLD.job_title THEN
        SET audit_log = CONCAT(audit_log, "Job Title: ", OLD.job_title, " -> ", NEW.job_title, "<br/>");
    END IF;

    IF NEW.employment_type_name <> OLD.employment_type_name THEN
        SET audit_log = CONCAT(audit_log, "Employment Type: ", OLD.employment_type_name, " -> ", NEW.employment_type_name, "<br/>");
    END IF;

    IF NEW.company_name <> OLD.company_name THEN
        SET audit_log = CONCAT(audit_log, "Company: ", OLD.company_name, " -> ", NEW.company_name, "<br/>");
    END IF;

    IF NEW.location <> OLD.location THEN
        SET audit_log = CONCAT(audit_log, "Location: ", OLD.location, " -> ", NEW.location, "<br/>");
    END IF;

    IF NEW.start_month <> OLD.start_month THEN
        SET audit_log = CONCAT(audit_log, "Start Month: ", OLD.start_month, " -> ", NEW.start_month, "<br/>");
    END IF;

    IF NEW.start_year <> OLD.start_year THEN
        SET audit_log = CONCAT(audit_log, "Start Year: ", OLD.start_year, " -> ", NEW.start_year, "<br/>");
    END IF;

    IF NEW.end_month <> OLD.end_month THEN
        SET audit_log = CONCAT(audit_log, "End Month: ", OLD.end_month, " -> ", NEW.end_month, "<br/>");
    END IF;

    IF NEW.end_year <> OLD.end_year THEN
        SET audit_log = CONCAT(audit_log, "End Year: ", OLD.end_year, " -> ", NEW.end_year, "<br/>");
    END IF;

    IF NEW.job_description <> OLD.job_description THEN
        SET audit_log = CONCAT(audit_log, "Job Description: ", OLD.job_description, " -> ", NEW.job_description, "<br/>");
    END IF;
    
    IF audit_log <> 'Employee experience changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employee_experience', NEW.employee_experience_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_experience_insert//

CREATE TRIGGER trg_employee_experience_insert
AFTER INSERT ON employee_experience
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee experience created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee_experience', NEW.employee_experience_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE EDUCATION
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_education_update//

CREATE TRIGGER trg_employee_education_update
AFTER UPDATE ON employee_education
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee education changed.<br/><br/>';

    IF NEW.school <> OLD.school THEN
        SET audit_log = CONCAT(audit_log, "School: ", OLD.school, " -> ", NEW.school, "<br/>");
    END IF;

    IF NEW.degree <> OLD.degree THEN
        SET audit_log = CONCAT(audit_log, "Degree: ", OLD.degree, " -> ", NEW.degree, "<br/>");
    END IF;

    IF NEW.field_of_study <> OLD.field_of_study THEN
        SET audit_log = CONCAT(audit_log, "Field of Study: ", OLD.field_of_study, " -> ", NEW.field_of_study, "<br/>");
    END IF;

    IF NEW.start_month <> OLD.start_month THEN
        SET audit_log = CONCAT(audit_log, "Start Month: ", OLD.start_month, " -> ", NEW.start_month, "<br/>");
    END IF;

    IF NEW.start_year <> OLD.start_year THEN
        SET audit_log = CONCAT(audit_log, "Start Year: ", OLD.start_year, " -> ", NEW.start_year, "<br/>");
    END IF;

    IF NEW.end_month <> OLD.end_month THEN
        SET audit_log = CONCAT(audit_log, "End Month: ", OLD.end_month, " -> ", NEW.end_month, "<br/>");
    END IF;

    IF NEW.end_year <> OLD.end_year THEN
        SET audit_log = CONCAT(audit_log, "End Year: ", OLD.end_year, " -> ", NEW.end_year, "<br/>");
    END IF;

    IF NEW.activities_societies <> OLD.activities_societies THEN
        SET audit_log = CONCAT(audit_log, "Activities/Societies: ", OLD.activities_societies, " -> ", NEW.activities_societies, "<br/>");
    END IF;

    IF NEW.education_description <> OLD.education_description THEN
        SET audit_log = CONCAT(audit_log, "Description: ", OLD.education_description, " -> ", NEW.education_description, "<br/>");
    END IF;
    
    IF audit_log <> 'Employee education changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employee_education', NEW.employee_education_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_education_insert//

CREATE TRIGGER trg_employee_education_insert
AFTER INSERT ON employee_education
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee education created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee_education', NEW.employee_education_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE LICENSE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_license_update//

CREATE TRIGGER trg_employee_license_update
AFTER UPDATE ON employee_license
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee license changed.<br/><br/>';

    IF NEW.licensed_profession <> OLD.licensed_profession THEN
        SET audit_log = CONCAT(audit_log, "Licensed Profession: ", OLD.licensed_profession, " -> ", NEW.licensed_profession, "<br/>");
    END IF;

    IF NEW.licensing_body <> OLD.licensing_body THEN
        SET audit_log = CONCAT(audit_log, "Licensing Body: ", OLD.licensing_body, " -> ", NEW.licensing_body, "<br/>");
    END IF;

    IF NEW.license_number <> OLD.license_number THEN
        SET audit_log = CONCAT(audit_log, "License Number: ", OLD.license_number, " -> ", NEW.license_number, "<br/>");
    END IF;

    IF NEW.issue_date <> OLD.issue_date THEN
        SET audit_log = CONCAT(audit_log, "Issue Date: ", OLD.issue_date, " -> ", NEW.issue_date, "<br/>");
    END IF;

    IF NEW.expiration_date <> OLD.expiration_date THEN
        SET audit_log = CONCAT(audit_log, "Expiration Date: ", OLD.expiration_date, " -> ", NEW.expiration_date, "<br/>");
    END IF;
    
    IF audit_log <> 'Employee license changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employee_license', NEW.employee_license_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_license_insert//

CREATE TRIGGER trg_employee_license_insert
AFTER INSERT ON employee_license
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee license created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee_license', NEW.employee_license_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE EMERGENCY CONTACT
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_emergency_contact_update//

CREATE TRIGGER trg_employee_emergency_contact_update
AFTER UPDATE ON employee_emergency_contact
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee emergency contact changed.<br/><br/>';

    IF NEW.emergency_contact_name <> OLD.emergency_contact_name THEN
        SET audit_log = CONCAT(audit_log, "Emergency Contact Name: ", OLD.emergency_contact_name, " -> ", NEW.emergency_contact_name, "<br/>");
    END IF;

    IF NEW.relationship_name <> OLD.relationship_name THEN
        SET audit_log = CONCAT(audit_log, "Relationship: ", OLD.relationship_name, " -> ", NEW.relationship_name, "<br/>");
    END IF;

    IF NEW.telephone <> OLD.telephone THEN
        SET audit_log = CONCAT(audit_log, "Telephone: ", OLD.telephone, " -> ", NEW.telephone, "<br/>");
    END IF;

    IF NEW.mobile <> OLD.mobile THEN
        SET audit_log = CONCAT(audit_log, "Mobile: ", OLD.mobile, " -> ", NEW.mobile, "<br/>");
    END IF;

    IF NEW.email <> OLD.email THEN
        SET audit_log = CONCAT(audit_log, "Email: ", OLD.email, " -> ", NEW.email, "<br/>");
    END IF;
    
    IF audit_log <> 'Employee emergency contact changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employee_emergency_contact', NEW.employee_emergency_contact_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_emergency_contact_insert//

CREATE TRIGGER trg_employee_emergency_contact_insert
AFTER INSERT ON employee_emergency_contact
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee emergency contact created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee_emergency_contact', NEW.employee_emergency_contact_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE LANGUAGE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_language_update//

CREATE TRIGGER trg_employee_language_update
AFTER UPDATE ON employee_language
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee language changed.<br/><br/>';

    IF NEW.language_name <> OLD.language_name THEN
        SET audit_log = CONCAT(audit_log, "Language: ", OLD.language_name, " -> ", NEW.language_name, "<br/>");
    END IF;

    IF NEW.language_proficiency_name <> OLD.language_proficiency_name THEN
        SET audit_log = CONCAT(audit_log, "Language Proficiency: ", OLD.language_proficiency_name, " -> ", NEW.language_proficiency_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Employee language changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employee_language', NEW.employee_language_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_language_insert//

CREATE TRIGGER trg_employee_language_insert
AFTER INSERT ON employee_language
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee language created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee_language', NEW.employee_language_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE DOCUMENT
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_document_insert//

CREATE TRIGGER trg_employee_document_insert
AFTER INSERT ON employee_document
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employee document created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee_document', NEW.employee_document_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: EMPLOYEE DOCUMENT TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_document_type_update//

CREATE TRIGGER trg_employee_document_type_update
AFTER UPDATE ON employee_document_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employment document type changed.<br/><br/>';

    IF NEW.employee_document_type_name <> OLD.employee_document_type_name THEN
        SET audit_log = CONCAT(audit_log, "Employment Document Type Name: ", OLD.employee_document_type_name, " -> ", NEW.employee_document_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Employment document type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('employee_document_type', NEW.employee_document_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_employee_document_type_insert//

CREATE TRIGGER trg_employee_document_type_insert
AFTER INSERT ON employee_document_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Employment document type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('employee_document_type', NEW.employee_document_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: ATTRIBUTE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_attribute_update//

CREATE TRIGGER trg_attribute_update
AFTER UPDATE ON attribute
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Attribute changed.<br/><br/>';

    IF NEW.attribute_name <> OLD.attribute_name THEN
        SET audit_log = CONCAT(audit_log, "Attribute Name: ", OLD.attribute_name, " -> ", NEW.attribute_name, "<br/>");
    END IF;

    IF NEW.attribute_description <> OLD.attribute_description THEN
        SET audit_log = CONCAT(audit_log, "Attribute Description: ", OLD.attribute_description, " -> ", NEW.attribute_description, "<br/>");
    END IF;

    IF NEW.variant_creation <> OLD.variant_creation THEN
        SET audit_log = CONCAT(audit_log, "Variant Creation: ", OLD.variant_creation, " -> ", NEW.variant_creation, "<br/>");
    END IF;

    IF NEW.display_type <> OLD.display_type THEN
        SET audit_log = CONCAT(audit_log, "Display Type: ", OLD.display_type, " -> ", NEW.display_type, "<br/>");
    END IF;
    
    IF audit_log <> 'Attribute changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('attribute', NEW.attribute_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_attribute_insert//

CREATE TRIGGER trg_attribute_insert
AFTER INSERT ON attribute
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Attribute created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('attribute', NEW.attribute_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: ATTRIBUTE VALUE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_attribute_value_update//

CREATE TRIGGER trg_attribute_value_update
AFTER UPDATE ON attribute_value
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Attribute value changed.<br/><br/>';

    IF NEW.attribute_value_name <> OLD.attribute_value_name THEN
        SET audit_log = CONCAT(audit_log, "Attribute Value Name: ", OLD.attribute_value_name, " -> ", NEW.attribute_value_name, "<br/>");
    END IF;

    IF NEW.attribute_name <> OLD.attribute_name THEN
        SET audit_log = CONCAT(audit_log, "Attribute Name: ", OLD.attribute_name, " -> ", NEW.attribute_name, "<br/>");
    END IF;

    IF audit_log <> 'Attribute value changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('attribute_value', NEW.attribute_value_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_attribute_value_insert//

CREATE TRIGGER trg_attribute_value_insert
AFTER INSERT ON attribute_value
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Attribute value created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('attribute_value', NEW.attribute_value_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: TAX
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_tax_update//

CREATE TRIGGER trg_tax_update
AFTER UPDATE ON tax
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Tax changed.<br/><br/>';

    IF NEW.tax_name <> OLD.tax_name THEN
        SET audit_log = CONCAT(audit_log, "Tax Name: ", OLD.tax_name, " -> ", NEW.tax_name, "<br/>");
    END IF;

    IF NEW.tax_rate <> OLD.tax_rate THEN
        SET audit_log = CONCAT(audit_log, "Tax Rate: ", OLD.tax_rate, " -> ", NEW.tax_rate, "<br/>");
    END IF;

    IF NEW.tax_type <> OLD.tax_type THEN
        SET audit_log = CONCAT(audit_log, "Tax Type: ", OLD.tax_type, " -> ", NEW.tax_type, "<br/>");
    END IF;

    IF NEW.tax_computation <> OLD.tax_computation THEN
        SET audit_log = CONCAT(audit_log, "Tax Computation: ", OLD.tax_computation, " -> ", NEW.tax_computation, "<br/>");
    END IF;

    IF NEW.tax_scope <> OLD.tax_scope THEN
        SET audit_log = CONCAT(audit_log, "Tax Scope: ", OLD.tax_scope, " -> ", NEW.tax_scope, "<br/>");
    END IF;

    IF NEW.tax_status <> OLD.tax_status THEN
        SET audit_log = CONCAT(audit_log, "Tax Status: ", OLD.tax_status, " -> ", NEW.tax_status, "<br/>");
    END IF;

    IF audit_log <> 'Tax changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('tax', NEW.tax_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_tax_insert//

CREATE TRIGGER trg_tax_insert
AFTER INSERT ON tax
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Tax created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('tax', NEW.tax_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PRODUCT CATEGORY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_category_update//

CREATE TRIGGER trg_product_category_update
AFTER UPDATE ON product_category
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product category changed.<br/><br/>';

    IF NEW.product_category_name <> OLD.product_category_name THEN
        SET audit_log = CONCAT(audit_log, "Product Category Name: ", OLD.product_category_name, " -> ", NEW.product_category_name, "<br/>");
    END IF;

    IF NEW.parent_category_name <> OLD.parent_category_name THEN
        SET audit_log = CONCAT(audit_log, "Parent Category: ", OLD.parent_category_name, " -> ", NEW.parent_category_name, "<br/>");
    END IF;

    IF NEW.costing_method <> OLD.costing_method THEN
        SET audit_log = CONCAT(audit_log, "Costing Method: ", OLD.costing_method, " -> ", NEW.costing_method, "<br/>");
    END IF;

    IF NEW.display_order <> OLD.display_order THEN
        SET audit_log = CONCAT(audit_log, "Display Order: ", OLD.display_order, " -> ", NEW.display_order, "<br/>");
    END IF;
    
    IF audit_log <> 'Product category changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('product_category', NEW.product_category_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_category_insert//

CREATE TRIGGER trg_product_category_insert
AFTER INSERT ON product_category
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product category created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('product_category', NEW.product_category_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: SUPPLIER
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_supplier_update//

CREATE TRIGGER trg_supplier_update
AFTER UPDATE ON supplier
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Supplier changed.<br/><br/>';

    IF NEW.supplier_name <> OLD.supplier_name THEN
        SET audit_log = CONCAT(audit_log, "Supplier Name: ", OLD.supplier_name, " -> ", NEW.supplier_name, "<br/>");
    END IF;

    IF NEW.contact_person <> OLD.contact_person THEN
        SET audit_log = CONCAT(audit_log, "Contact Person: ", OLD.contact_person, " -> ", NEW.contact_person, "<br/>");
    END IF;

    IF NEW.phone <> OLD.phone THEN
        SET audit_log = CONCAT(audit_log, "Phone: ", OLD.phone, " -> ", NEW.phone, "<br/>");
    END IF;

    IF NEW.telephone <> OLD.telephone THEN
        SET audit_log = CONCAT(audit_log, "Telephone: ", OLD.telephone, " -> ", NEW.telephone, "<br/>");
    END IF;

    IF NEW.email <> OLD.email THEN
        SET audit_log = CONCAT(audit_log, "Email: ", OLD.email, " -> ", NEW.email, "<br/>");
    END IF;

    IF NEW.address <> OLD.address THEN
        SET audit_log = CONCAT(audit_log, "Address: ", OLD.address, " -> ", NEW.address, "<br/>");
    END IF;

    IF NEW.city_name <> OLD.city_name THEN
        SET audit_log = CONCAT(audit_log, "City: ", OLD.city_name, " -> ", NEW.city_name, "<br/>");
    END IF;

    IF NEW.state_name <> OLD.state_name THEN
        SET audit_log = CONCAT(audit_log, "State: ", OLD.state_name, " -> ", NEW.state_name, "<br/>");
    END IF;

    IF NEW.country_name <> OLD.country_name THEN
        SET audit_log = CONCAT(audit_log, "Country: ", OLD.country_name, " -> ", NEW.country_name, "<br/>");
    END IF;

    IF NEW.tax_id_number <> OLD.tax_id_number THEN
        SET audit_log = CONCAT(audit_log, "Tax ID Number: ", OLD.tax_id_number, " -> ", NEW.tax_id_number, "<br/>");
    END IF;

    IF NEW.supplier_status <> OLD.supplier_status THEN
        SET audit_log = CONCAT(audit_log, "Supplier Status: ", OLD.supplier_status, " -> ", NEW.supplier_status, "<br/>");
    END IF;

    IF audit_log <> 'Supplier changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('supplier', NEW.supplier_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_supplier_insert//

CREATE TRIGGER trg_supplier_insert
AFTER INSERT ON supplier
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Supplier created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('supplier', NEW.supplier_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: WAREHOUSE TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_warehouse_type_update//

CREATE TRIGGER trg_warehouse_type_update
AFTER UPDATE ON warehouse_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Warehouse type changed.<br/><br/>';

    IF NEW.warehouse_type_name <> OLD.warehouse_type_name THEN
        SET audit_log = CONCAT(audit_log, "Warehouse Type Name: ", OLD.warehouse_type_name, " -> ", NEW.warehouse_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Warehouse type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('warehouse_type', NEW.warehouse_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_warehouse_type_insert//

CREATE TRIGGER trg_warehouse_type_insert
AFTER INSERT ON warehouse_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Warehouse type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('warehouse_type', NEW.warehouse_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: WAREHOUSE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_warehouse_update//

CREATE TRIGGER trg_warehouse_update
AFTER UPDATE ON warehouse
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Warehouse changed.<br/><br/>';

    IF NEW.warehouse_name <> OLD.warehouse_name THEN
        SET audit_log = CONCAT(audit_log, "Warehouse Name: ", OLD.warehouse_name, " -> ", NEW.warehouse_name, "<br/>");
    END IF;

    IF NEW.short_name <> OLD.short_name THEN
        SET audit_log = CONCAT(audit_log, "Short Name: ", OLD.short_name, " -> ", NEW.short_name, "<br/>");
    END IF;

    IF NEW.contact_person <> OLD.contact_person THEN
        SET audit_log = CONCAT(audit_log, "Contact Person: ", OLD.contact_person, " -> ", NEW.contact_person, "<br/>");
    END IF;

    IF NEW.phone <> OLD.phone THEN
        SET audit_log = CONCAT(audit_log, "Phone: ", OLD.phone, " -> ", NEW.phone, "<br/>");
    END IF;

    IF NEW.telephone <> OLD.telephone THEN
        SET audit_log = CONCAT(audit_log, "Telephone: ", OLD.telephone, " -> ", NEW.telephone, "<br/>");
    END IF;

    IF NEW.email <> OLD.email THEN
        SET audit_log = CONCAT(audit_log, "Email: ", OLD.email, " -> ", NEW.email, "<br/>");
    END IF;

    IF NEW.address <> OLD.address THEN
        SET audit_log = CONCAT(audit_log, "Address: ", OLD.address, " -> ", NEW.address, "<br/>");
    END IF;

    IF NEW.city_name <> OLD.city_name THEN
        SET audit_log = CONCAT(audit_log, "City: ", OLD.city_name, " -> ", NEW.city_name, "<br/>");
    END IF;

    IF NEW.state_name <> OLD.state_name THEN
        SET audit_log = CONCAT(audit_log, "State: ", OLD.state_name, " -> ", NEW.state_name, "<br/>");
    END IF;

    IF NEW.country_name <> OLD.country_name THEN
        SET audit_log = CONCAT(audit_log, "Country: ", OLD.country_name, " -> ", NEW.country_name, "<br/>");
    END IF;

    IF NEW.warehouse_type_name <> OLD.warehouse_type_name THEN
        SET audit_log = CONCAT(audit_log, "Warehouse Type: ", OLD.warehouse_type_name, " -> ", NEW.warehouse_type_name, "<br/>");
    END IF;

    IF NEW.warehouse_status <> OLD.warehouse_status THEN
        SET audit_log = CONCAT(audit_log, "Warehouse Status: ", OLD.warehouse_status, " -> ", NEW.warehouse_status, "<br/>");
    END IF;
    
    IF audit_log <> 'Warehouse changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('warehouse', NEW.warehouse_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_warehouse_insert//

CREATE TRIGGER trg_warehouse_insert
AFTER INSERT ON warehouse
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Warehouse created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('warehouse', NEW.warehouse_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: UOM TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_unit_type_update//

CREATE TRIGGER trg_unit_type_update
AFTER UPDATE ON unit_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Unit type changed.<br/><br/>';

    IF NEW.unit_type_name <> OLD.unit_type_name THEN
        SET audit_log = CONCAT(audit_log, "Unit Type Name: ", OLD.unit_type_name, " -> ", NEW.unit_type_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Unit type changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('unit_type', NEW.unit_type_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_unit_type_insert//

CREATE TRIGGER trg_unit_type_insert
AFTER INSERT ON unit_type
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Unit type created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('unit_type', NEW.unit_type_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: UOM
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_unit_update//

CREATE TRIGGER trg_unit_update
AFTER UPDATE ON unit
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Unit changed.<br/><br/>';

    IF NEW.unit_name <> OLD.unit_name THEN
        SET audit_log = CONCAT(audit_log, "Unit Name: ", OLD.unit_name, " -> ", NEW.unit_name, "<br/>");
    END IF;

    IF NEW.unit_abbreviation <> OLD.unit_abbreviation THEN
        SET audit_log = CONCAT(audit_log, "Unit Abbreviation: ", OLD.unit_abbreviation, " -> ", NEW.unit_abbreviation, "<br/>");
    END IF;

    IF NEW.unit_type_name <> OLD.unit_type_name THEN
        SET audit_log = CONCAT(audit_log, "Unit Type: ", OLD.unit_type_name, " -> ", NEW.unit_type_name, "<br/>");
    END IF;

    IF NEW.ratio_to_base <> OLD.ratio_to_base THEN
        SET audit_log = CONCAT(audit_log, "Ratio to Base: ", OLD.ratio_to_base, " -> ", NEW.ratio_to_base, "<br/>");
    END IF;
    
    IF audit_log <> 'Unit changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('unit', NEW.unit_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_unit_insert//

CREATE TRIGGER trg_unit_insert
AFTER INSERT ON unit
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Unit created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('unit', NEW.unit_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PRODUCT
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_update//

CREATE TRIGGER trg_product_update
AFTER UPDATE ON product
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product changed.<br/><br/>';

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product Name: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.product_description <> OLD.product_description THEN
        SET audit_log = CONCAT(audit_log, "Product Description: ", OLD.product_description, " -> ", NEW.product_description, "<br/>");
    END IF;

    IF NEW.parent_product_name <> OLD.parent_product_name THEN
        SET audit_log = CONCAT(audit_log, "Parent Product: ", OLD.parent_product_name, " -> ", NEW.parent_product_name, "<br/>");
    END IF;

    IF NEW.product_type <> OLD.product_type THEN
        SET audit_log = CONCAT(audit_log, "Product Type: ", OLD.product_type, " -> ", NEW.product_type, "<br/>");
    END IF;

    IF NEW.sku <> OLD.sku THEN
        SET audit_log = CONCAT(audit_log, "SKU: ", OLD.sku, " -> ", NEW.sku, "<br/>");
    END IF;

    IF NEW.barcode <> OLD.barcode THEN
        SET audit_log = CONCAT(audit_log, "Barcode: ", OLD.barcode, " -> ", NEW.barcode, "<br/>");
    END IF;

    IF NEW.unit_name <> OLD.unit_name THEN
        SET audit_log = CONCAT(audit_log, "Unit: ", OLD.unit_name, " -> ", NEW.unit_name, "<br/>");
    END IF;

    IF NEW.unit_abbreviation <> OLD.unit_abbreviation THEN
        SET audit_log = CONCAT(audit_log, "Unit Abbreviation: ", OLD.unit_abbreviation, " -> ", NEW.unit_abbreviation, "<br/>");
    END IF;

    IF NEW.quantity_on_hand <> OLD.quantity_on_hand THEN
        SET audit_log = CONCAT(audit_log, "Quantity On Hand: ", OLD.quantity_on_hand, " -> ", NEW.quantity_on_hand, "<br/>");
    END IF;

    IF NEW.cost <> OLD.cost THEN
        SET audit_log = CONCAT(audit_log, "Cost: ", OLD.cost, " -> ", NEW.cost, "<br/>");
    END IF;

    IF NEW.sales_price <> OLD.sales_price THEN
        SET audit_log = CONCAT(audit_log, "Sales Price: ", OLD.sales_price, " -> ", NEW.sales_price, "<br/>");
    END IF;

    IF NEW.is_variant <> OLD.is_variant THEN
        SET audit_log = CONCAT(audit_log, "Is Variant: ", OLD.is_variant, " -> ", NEW.is_variant, "<br/>");
    END IF;

    IF NEW.is_sellable <> OLD.is_sellable THEN
        SET audit_log = CONCAT(audit_log, "Is Sellable: ", OLD.is_sellable, " -> ", NEW.is_sellable, "<br/>");
    END IF;

    IF NEW.is_purchasable <> OLD.is_purchasable THEN
        SET audit_log = CONCAT(audit_log, "Is Purchasable: ", OLD.is_purchasable, " -> ", NEW.is_purchasable, "<br/>");
    END IF;

    IF NEW.show_on_pos <> OLD.show_on_pos THEN
        SET audit_log = CONCAT(audit_log, "Show on POS: ", OLD.show_on_pos, " -> ", NEW.show_on_pos, "<br/>");
    END IF;
    
    IF NEW.weight <> OLD.weight THEN
        SET audit_log = CONCAT(audit_log, "Weight: ", OLD.weight, " -> ", NEW.weight, " kg<br/>");
    END IF;

    IF NEW.width <> OLD.width THEN
        SET audit_log = CONCAT(audit_log, "Width: ", OLD.width, " -> ", NEW.width, " cm<br/>");
    END IF;

    IF NEW.height <> OLD.height THEN
        SET audit_log = CONCAT(audit_log, "Height: ", OLD.height, " -> ", NEW.height, " cm<br/>");
    END IF;

    IF NEW.length <> OLD.length THEN
        SET audit_log = CONCAT(audit_log, "Length: ", OLD.length, " -> ", NEW.length, " cm<br/>");
    END IF;

    IF NEW.variant_signature <> OLD.variant_signature THEN
        SET audit_log = CONCAT(audit_log, "Variant Signature: ", OLD.variant_signature, " -> ", NEW.variant_signature, "<br/>");
    END IF;

    IF NEW.product_status <> OLD.product_status THEN
        SET audit_log = CONCAT(audit_log, "Product Status: ", OLD.product_status, " -> ", NEW.product_status, "<br/>");
    END IF;
    
    IF audit_log <> 'Product changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('product', NEW.product_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_insert//

CREATE TRIGGER trg_product_insert
AFTER INSERT ON product
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('product', NEW.product_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PRODUCT TAX
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_tax_update//

CREATE TRIGGER trg_product_tax_update
AFTER UPDATE ON product_tax
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product tax changed.<br/><br/>';

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.tax_type <> OLD.tax_type THEN
        SET audit_log = CONCAT(audit_log, "Tax Type: ", OLD.tax_type, " -> ", NEW.tax_type, "<br/>");
    END IF;

    IF NEW.tax_name <> OLD.tax_name THEN
        SET audit_log = CONCAT(audit_log, "Tax: ", OLD.tax_name, " -> ", NEW.tax_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Product tax changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('product_tax', NEW.product_tax_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_tax_insert//

CREATE TRIGGER trg_product_tax_insert
AFTER INSERT ON product_tax
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product tax created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('product_tax', NEW.product_tax_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PRODUCT CATEGORIES
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_category_map_update//

CREATE TRIGGER trg_product_category_map_update
AFTER UPDATE ON product_category_map
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product category map changed.<br/><br/>';

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.product_category_name <> OLD.product_category_name THEN
        SET audit_log = CONCAT(audit_log, "Product Category: ", OLD.product_category_name, " -> ", NEW.product_category_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Product category map changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('product_category_map', NEW.product_category_map_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_category_map_insert//

CREATE TRIGGER trg_product_category_map_insert
AFTER INSERT ON product_category_map
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product category map created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('product_category_map', NEW.product_category_map_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PRODUCT ATTRIBUTE
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_attribute_update//

CREATE TRIGGER trg_product_attribute_update
AFTER UPDATE ON product_attribute
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product attribute changed.<br/><br/>';

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.attribute_name <> OLD.attribute_name THEN
        SET audit_log = CONCAT(audit_log, "Attribute: ", OLD.attribute_name, " -> ", NEW.attribute_name, "<br/>");
    END IF;

    IF NEW.attribute_value_name <> OLD.attribute_value_name THEN
        SET audit_log = CONCAT(audit_log, "Attribute Value: ", OLD.attribute_value_name, " -> ", NEW.attribute_value_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Product attribute changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('product_attribute', NEW.product_attribute_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_attribute_insert//

CREATE TRIGGER trg_product_attribute_insert
AFTER INSERT ON product_attribute
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product attribute created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('product_attribute', NEW.product_attribute_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PRODUCT VARIANT
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_variant_update//

CREATE TRIGGER trg_product_variant_update
AFTER UPDATE ON product_variant
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product variant changed.<br/><br/>';

    IF NEW.parent_product_name <> OLD.parent_product_name THEN
        SET audit_log = CONCAT(audit_log, "Parent Product: ", OLD.parent_product_name, " -> ", NEW.parent_product_name, "<br/>");
    END IF;

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.attribute_name <> OLD.attribute_name THEN
        SET audit_log = CONCAT(audit_log, "Attribute: ", OLD.attribute_name, " -> ", NEW.attribute_name, "<br/>");
    END IF;

    IF NEW.attribute_value_name <> OLD.attribute_value_name THEN
        SET audit_log = CONCAT(audit_log, "Attribute Value: ", OLD.attribute_value_name, " -> ", NEW.attribute_value_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Product variant changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('product_variant', NEW.product_variant_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_variant_insert//

CREATE TRIGGER trg_product_variant_insert
AFTER INSERT ON product_variant
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product variant created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('product_variant', NEW.product_variant_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PRODUCT PRICELIST
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_pricelist_update//

CREATE TRIGGER trg_product_pricelist_update
AFTER UPDATE ON product_pricelist
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product pricelist changed.<br/><br/>';

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.discount_type <> OLD.discount_type THEN
        SET audit_log = CONCAT(audit_log, "Discount Type: ", OLD.discount_type, " -> ", NEW.discount_type, "<br/>");
    END IF;

    IF NEW.fixed_price <> OLD.fixed_price THEN
        SET audit_log = CONCAT(audit_log, "Fixed Price: ", OLD.fixed_price, " -> ", NEW.fixed_price, "<br/>");
    END IF;

    IF NEW.min_quantity <> OLD.min_quantity THEN
        SET audit_log = CONCAT(audit_log, "Minimum Quantity: ", OLD.min_quantity, " -> ", NEW.min_quantity, "<br/>");
    END IF;

    IF NEW.validity_start_date <> OLD.validity_start_date THEN
        SET audit_log = CONCAT(audit_log, "Validity Start Date: ", OLD.validity_start_date, " -> ", NEW.validity_start_date, "<br/>");
    END IF;

    IF NEW.validity_end_date <> OLD.validity_end_date THEN
        SET audit_log = CONCAT(audit_log, "Validity End Date: ", OLD.validity_end_date, " -> ", NEW.validity_end_date, "<br/>");
    END IF;

    IF NEW.remarks <> OLD.remarks THEN
        SET audit_log = CONCAT(audit_log, "Remarks: ", OLD.remarks, " -> ", NEW.remarks, "<br/>");
    END IF;
    
    IF audit_log <> 'Product pricelist changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('product_pricelist', NEW.product_pricelist_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_product_pricelist_insert//

CREATE TRIGGER trg_product_pricelist_insert
AFTER INSERT ON product_pricelist
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Product pricelist created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('product_pricelist', NEW.product_pricelist_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: PHYSICAL INVENTORY
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_physical_inventory_update//

CREATE TRIGGER trg_physical_inventory_update
AFTER UPDATE ON physical_inventory
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Physical inventory changed.<br/><br/>';

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.physical_inventory_status <> OLD.physical_inventory_status THEN
        SET audit_log = CONCAT(audit_log, "Physical Inventory Status: ", OLD.physical_inventory_status, " -> ", NEW.physical_inventory_status, "<br/>");
    END IF;

    IF NEW.quantity_on_hand <> OLD.quantity_on_hand THEN
        SET audit_log = CONCAT(audit_log, "Quantity On Hand: ", OLD.quantity_on_hand, " -> ", NEW.quantity_on_hand, "<br/>");
    END IF;

    IF NEW.inventory_count <> OLD.inventory_count THEN
        SET audit_log = CONCAT(audit_log, "Inventory Count: ", OLD.inventory_count, " -> ", NEW.inventory_count, "<br/>");
    END IF;

    IF NEW.inventory_difference <> OLD.inventory_difference THEN
        SET audit_log = CONCAT(audit_log, "Inventory Difference: ", OLD.inventory_difference, " -> ", NEW.inventory_difference, "<br/>");
    END IF;

    IF NEW.inventory_date <> OLD.inventory_date THEN
        SET audit_log = CONCAT(audit_log, "Inventory Date: ", OLD.inventory_date, " -> ", NEW.inventory_date, "<br/>");
    END IF;

    IF NEW.applied_date <> OLD.applied_date THEN
        SET audit_log = CONCAT(audit_log, "Applied Date: ", OLD.applied_date, " -> ", NEW.applied_date, "<br/>");
    END IF;

    IF NEW.remarks <> OLD.remarks THEN
        SET audit_log = CONCAT(audit_log, "Remarks: ", OLD.remarks, " -> ", NEW.remarks, "<br/>");
    END IF;
    
    IF audit_log <> 'Physical inventory changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('physical_inventory', NEW.physical_inventory_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_physical_inventory_insert//

CREATE TRIGGER trg_physical_inventory_insert
AFTER INSERT ON physical_inventory
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Physical inventory created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('physical_inventory', NEW.physical_inventory_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: SCRAP REASON
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_scrap_reason_update//

CREATE TRIGGER trg_scrap_reason_update
AFTER UPDATE ON scrap_reason
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Scrap reason changed.<br/><br/>';

    IF NEW.scrap_reason_name <> OLD.scrap_reason_name THEN
        SET audit_log = CONCAT(audit_log, "Scrap Reason Name: ", OLD.scrap_reason_name, " -> ", NEW.scrap_reason_name, "<br/>");
    END IF;
    
    IF audit_log <> 'Scrap reason changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('scrap_reason', NEW.scrap_reason_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_scrap_reason_insert//

CREATE TRIGGER trg_scrap_reason_insert
AFTER INSERT ON scrap_reason
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Scrap reason created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('scrap_reason', NEW.scrap_reason_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: INVENTORY SCRAP
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_inventory_scrap_update//

CREATE TRIGGER trg_inventory_scrap_update
AFTER UPDATE ON inventory_scrap
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Inventory scrap changed.<br/><br/>';

    IF NEW.product_name <> OLD.product_name THEN
        SET audit_log = CONCAT(audit_log, "Product: ", OLD.product_name, " -> ", NEW.product_name, "<br/>");
    END IF;

    IF NEW.reference_number <> OLD.reference_number THEN
        SET audit_log = CONCAT(audit_log, "Reference Number: ", OLD.reference_number, " -> ", NEW.reference_number, "<br/>");
    END IF;

    IF NEW.inventory_scrap_status <> OLD.inventory_scrap_status THEN
        SET audit_log = CONCAT(audit_log, "Inventory Scrap Status: ", OLD.inventory_scrap_status, " -> ", NEW.inventory_scrap_status, "<br/>");
    END IF;

    IF NEW.quantity_on_hand <> OLD.quantity_on_hand THEN
        SET audit_log = CONCAT(audit_log, "Quantity On Hand: ", OLD.quantity_on_hand, " -> ", NEW.quantity_on_hand, "<br/>");
    END IF;

    IF NEW.scrap_quantity <> OLD.scrap_quantity THEN
        SET audit_log = CONCAT(audit_log, "Scrap Quantity: ", OLD.scrap_quantity, " -> ", NEW.scrap_quantity, "<br/>");
    END IF;

    IF NEW.scrap_reason_name <> OLD.scrap_reason_name THEN
        SET audit_log = CONCAT(audit_log, "Scrap Reason: ", OLD.scrap_reason_name, " -> ", NEW.scrap_reason_name, "<br/>");
    END IF;

    IF NEW.detailed_scrap_reason <> OLD.detailed_scrap_reason THEN
        SET audit_log = CONCAT(audit_log, "Detailed Scrap Reason: ", OLD.detailed_scrap_reason, " -> ", NEW.detailed_scrap_reason, "<br/>");
    END IF;

    IF NEW.completed_date <> OLD.completed_date THEN
        SET audit_log = CONCAT(audit_log, "Completed Date: ", OLD.completed_date, " -> ", NEW.completed_date, "<br/>");
    END IF;
    
    IF audit_log <> 'Inventory scrap changed.<br/><br/>' THEN
        INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
        VALUES ('inventory_scrap', NEW.inventory_scrap_id, audit_log, NEW.last_log_by, NOW());
    END IF;
END //

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

DROP TRIGGER IF EXISTS trg_inventory_scrap_insert//

CREATE TRIGGER trg_inventory_scrap_insert
AFTER INSERT ON inventory_scrap
FOR EACH ROW
BEGIN
    DECLARE audit_log TEXT DEFAULT 'Inventory scrap created.';

    INSERT INTO audit_log (table_name, reference_id, log, changed_by, changed_at) 
    VALUES ('inventory_scrap', NEW.inventory_scrap_id, audit_log, NEW.last_log_by, NOW());
END //

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */



/* =============================================================================================
   TRIGGER: 
============================================================================================= */

/* =============================================================================================
   SECTION 1: UPDATE TRIGGERS
============================================================================================= */

/* =============================================================================================
   SECTION 2: INSERT TRIGGERS
============================================================================================= */

/* =============================================================================================
   END OF TRIGGERS
============================================================================================= */