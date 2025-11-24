DELIMITER //

/* =============================================================================================
   STORED PROCEDURE: AUTHENTICATION
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveResetToken//

CREATE PROCEDURE saveResetToken(
    IN p_user_account_id INT,
    IN p_reset_token VARCHAR(255),
    IN p_reset_token_expiry_date DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_user_account_id IS NULL OR NOT EXISTS (SELECT 1 FROM reset_token WHERE user_account_id = p_user_account_id) THEN
        INSERT INTO reset_token (
            user_account_id,
            reset_token,
            reset_token_expiry_date
        )
        VALUES (
            p_user_account_id,
            p_reset_token,
            p_reset_token_expiry_date
        );
    ELSE
        UPDATE reset_token
        SET reset_token                 = p_reset_token,
            reset_token_expiry_date     = p_reset_token_expiry_date
        WHERE user_account_id           = p_user_account_id;
    END IF;
    
    COMMIT;
END //


DROP PROCEDURE IF EXISTS saveSession//

CREATE PROCEDURE saveSession(
    IN p_user_account_id INT,
    IN p_session_token VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE sessions
    SET session_token       = p_session_token
    WHERE user_account_id   = p_user_account_id;

    IF ROW_COUNT() = 0 THEN
        INSERT INTO sessions (
            user_account_id,
            session_token
        )
        VALUES (
            p_user_account_id,
            p_session_token
        );
    END IF;

    COMMIT;
END //


DROP PROCEDURE IF EXISTS saveOTP//

CREATE PROCEDURE saveOTP(
    IN p_user_account_id INT,
    IN p_otp VARCHAR(255),
    IN p_otp_expiry_date DATETIME
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE otp
    SET otp                 = p_otp,
        otp_expiry_date     = p_otp_expiry_date
    WHERE user_account_id   = p_user_account_id;

    IF ROW_COUNT() = 0 THEN
        INSERT INTO otp (
            user_account_id,
            otp,
            otp_expiry_date
        )
        VALUES (
            p_user_account_id,
            p_otp, p_otp_expiry_date
        );
    END IF;

    COMMIT;
END //


/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS insertLoginAttempt//

CREATE PROCEDURE insertLoginAttempt(
    IN p_user_account_id INT,
    IN p_email VARCHAR(255),
    IN p_ip_address VARCHAR(45),
    IN p_success TINYINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;
    DECLARE EXIT HANDLER FOR SQLWARNING ROLLBACK;

    START TRANSACTION;

    INSERT INTO login_attempts (
        user_account_id,
        email,
        ip_address,
        success
    )
    VALUES (
        p_user_account_id,
        p_email,
        p_ip_address,
        p_success
    );

    IF p_success = 1 THEN
        UPDATE user_account 
        SET last_connection_date    = NOW()
        WHERE user_account_id       = p_user_account_id;
    ELSE
        UPDATE user_account 
        SET last_failed_connection_date     = NOW()
        WHERE user_account_id               = p_user_account_id;
    END IF;

    COMMIT;
END //


/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateFailedOTPAttempts//

CREATE PROCEDURE updateFailedOTPAttempts(
    IN p_user_account_id INT,
    IN p_failed_otp_attempts TINYINT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE otp
    SET failed_otp_attempts     = p_failed_otp_attempts
    WHERE user_account_id       = p_user_account_id;

    COMMIT;
END //


DROP PROCEDURE IF EXISTS updateResetTokenAsExpired//

CREATE PROCEDURE updateResetTokenAsExpired(
    IN p_user_account_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE reset_token
    SET reset_token_expiry_date     = NOW()
    WHERE user_account_id           = p_user_account_id;

    COMMIT;
END //


DROP PROCEDURE IF EXISTS updateUserPassword//

CREATE PROCEDURE updateUserPassword(
    IN p_user_account_id INT,
    IN p_password VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE user_account
    SET password                = p_password,
        last_log_by             = p_user_account_id
    WHERE user_account_id       = p_user_account_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateOTPAsExpired//

CREATE PROCEDURE updateOTPAsExpired(
    IN p_user_account_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE otp
    SET otp_expiry_date     = NOW()
    WHERE user_account_id   = p_user_account_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchLoginCredentials//

CREATE PROCEDURE fetchLoginCredentials(
    IN p_credential VARCHAR(255)
)
BEGIN
    SELECT *
    FROM user_account
    WHERE user_account_id = CAST(p_credential AS UNSIGNED) OR email = BINARY p_credential
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchOTP//

CREATE PROCEDURE fetchOTP(
    IN p_user_account_id INT
)
BEGIN
    SELECT otp,
           otp_expiry_date,
           failed_otp_attempts
    FROM otp
    WHERE user_account_id = p_user_account_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchResetToken//

CREATE PROCEDURE fetchResetToken(
    IN p_user_account_id INT
)
BEGIN
    SELECT reset_token,
           reset_token_expiry_date
    FROM reset_token
    WHERE user_account_id = p_user_account_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchSession//

CREATE PROCEDURE fetchSession(
    IN p_user_account_id INT
)
BEGIN
    SELECT session_token
    FROM sessions
    WHERE user_account_id = p_user_account_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchAppModuleStack//

CREATE PROCEDURE fetchAppModuleStack(
    IN p_user_account_id INT
)
BEGIN
    SELECT DISTINCT(am.app_module_id) as app_module_id, am.app_module_name, am.menu_item_id, app_logo, app_module_description
    FROM app_module am
    JOIN menu_item mi ON mi.app_module_id = am.app_module_id
    WHERE EXISTS (
        SELECT 1
        FROM role_permission mar
        WHERE mar.menu_item_id = mi.menu_item_id
        AND mar.read_access = 1
        AND mar.role_id IN (
            SELECT role_id
            FROM role_user_account
            WHERE user_account_id = p_user_account_id
        )
    )
    ORDER BY am.order_sequence, am.app_module_name;
END //

DROP PROCEDURE IF EXISTS fetchLogNotes//

CREATE PROCEDURE fetchLogNotes(
    IN p_table_name VARCHAR(255),
    IN p_reference_id INT
)
BEGIN
	SELECT log, changed_by, changed_at
    FROM audit_log
    WHERE table_name = p_table_name AND reference_id  = p_reference_id
    ORDER BY changed_at DESC;
END //


/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkLoginCredentialsExist//

CREATE PROCEDURE checkLoginCredentialsExist(
    IN p_credential VARCHAR(255)
)
BEGIN
    SELECT COUNT(*) AS total
    FROM user_account
    WHERE user_account_id = CAST(p_credential AS UNSIGNED) OR email = BINARY p_credential;
END //

DROP PROCEDURE IF EXISTS checkUserSystemActionPermission//

CREATE PROCEDURE checkUserSystemActionPermission(
    IN p_user_account_id INT,
    IN p_system_action_id INT
)
BEGIN
    SELECT COUNT(role_id) AS total
    FROM role_system_action_permission 
    WHERE system_action_id = p_system_action_id
      AND system_action_access = 1
      AND role_id IN (
            SELECT role_id 
            FROM role_user_account 
            WHERE user_account_id = p_user_account_id
          );
END //

DROP PROCEDURE IF EXISTS checkUserPermission//

CREATE PROCEDURE checkUserPermission(
    IN p_user_account_id INT,
    IN p_menu_item_id INT,
    IN p_access_type VARCHAR(20)
)
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(rua.role_id) INTO v_total
    FROM role_user_account rua
    JOIN role_permission rp ON rua.role_id = rp.role_id
    WHERE rua.user_account_id = p_user_account_id
      AND rp.menu_item_id = p_menu_item_id
      AND (
            (p_access_type = 'read'      AND rp.read_access   = 1) OR
            (p_access_type = 'write'     AND rp.write_access  = 1) OR
            (p_access_type = 'create'    AND rp.create_access = 1) OR
            (p_access_type = 'delete'    AND rp.delete_access = 1) OR
            (p_access_type = 'import'    AND rp.import_access = 1) OR
            (p_access_type = 'export'    AND rp.export_access = 1) OR
            (p_access_type = 'log notes' AND rp.log_notes_access = 1)
        );

    SELECT v_total AS total;
END //

DROP PROCEDURE IF EXISTS checkRateLimited//

CREATE PROCEDURE checkRateLimited(
    IN p_email VARCHAR(255),
    IN p_ip_address VARCHAR(45),
    IN p_window INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM login_attempts
    WHERE attempt_time >= NOW() - INTERVAL p_window SECOND
      AND success = 0
      AND (ip_address = p_ip_address 
           OR email = p_email);
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: USER ACCOUNT
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS insertUserAccount//

CREATE PROCEDURE insertUserAccount(
    IN p_file_as VARCHAR(300), 
    IN p_email VARCHAR(255), 
    IN p_password VARCHAR(255),
    IN p_phone VARCHAR(50), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO user_account (
        file_as,
        email,
        password,
        phone,
        last_log_by
    ) 
    VALUES(
        p_file_as,
        p_email,
        p_password,
        p_phone,
        p_last_log_by
    );

    COMMIT;

    SELECT LAST_INSERT_ID() AS new_user_account_id;
END //

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateUserAccount //

CREATE PROCEDURE updateUserAccount (
    IN p_user_account_id INT, 
    IN p_value VARCHAR(500),
    IN p_update_type VARCHAR(50),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    CASE p_update_type
        WHEN 'email' THEN
            UPDATE user_account
            SET email               = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;

        WHEN 'phone' THEN
            UPDATE user_account
            SET phone               = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;

        WHEN 'password' THEN
            UPDATE user_account
            SET password                = p_value,
                last_password_change    = NOW(),
                last_log_by             = p_last_log_by
            WHERE user_account_id       = p_user_account_id;

        WHEN 'profile picture' THEN
            UPDATE user_account
            SET profile_picture     = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;

        WHEN 'two factor auth' THEN
            UPDATE user_account
            SET two_factor_auth     = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;

        WHEN 'multiple session' THEN
            UPDATE user_account
            SET multiple_session    = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;

        WHEN 'status' THEN
            UPDATE user_account
            SET active              = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;

        ELSE
            UPDATE role_user_account
            SET file_as             = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;

            UPDATE user_account
            SET file_as             = p_value,
                last_log_by         = p_last_log_by
            WHERE user_account_id   = p_user_account_id;
    END CASE;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchUserAccount//

CREATE PROCEDURE fetchUserAccount(
    IN p_user_account_id INT
)
BEGIN
	SELECT * FROM user_account
	WHERE user_account_id = p_user_account_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteUserAccount//

CREATE PROCEDURE deleteUserAccount(
    IN p_user_account_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM reset_token
    WHERE user_account_id = p_user_account_id;

    DELETE FROM otp
    WHERE user_account_id = p_user_account_id;

    DELETE FROM sessions
    WHERE user_account_id = p_user_account_id;

    DELETE FROM role_user_account
    WHERE user_account_id = p_user_account_id;

    DELETE FROM user_account
    WHERE user_account_id = p_user_account_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkUserAccountExist//

CREATE PROCEDURE checkUserAccountExist(
    IN p_user_account_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM user_account
    WHERE user_account_id = p_user_account_id;
END //

DROP PROCEDURE IF EXISTS checkUserAccountEmailExist//

CREATE PROCEDURE checkUserAccountEmailExist(
    IN p_user_account_id INT,
    IN p_email VARCHAR(255)
)
BEGIN
	SELECT COUNT(*) AS total
    FROM user_account
    WHERE user_account_id != p_user_account_id AND email = p_email;
END //

DROP PROCEDURE IF EXISTS checkUserAccountInsertEmailExist//

CREATE PROCEDURE checkUserAccountInsertEmailExist(
    IN p_email VARCHAR(255)
)
BEGIN
	SELECT COUNT(*) AS total
    FROM user_account
    WHERE email = p_email;
END //

DROP PROCEDURE IF EXISTS checkUserAccountPhoneExist//

CREATE PROCEDURE checkUserAccountPhoneExist(
    IN p_user_account_id INT,
    IN p_phone VARCHAR(50)
)
BEGIN
	SELECT COUNT(*) AS total
    FROM user_account
    WHERE user_account_id != p_user_account_id AND phone = p_phone;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateUserAccountTable//

CREATE PROCEDURE generateUserAccountTable(
    IN p_filter_by_active VARCHAR(5)
)
BEGIN
    DECLARE query TEXT DEFAULT 
        'SELECT user_account_id, file_as, email, profile_picture, active, last_connection_date, last_failed_connection_date
        FROM user_account WHERE 1=1';

    IF p_filter_by_active IS NOT NULL AND p_filter_by_active <> '' THEN
        SET query = CONCAT(query, ' AND active = ', QUOTE(p_filter_by_active));
    END IF;

    SET query = CONCAT(query, ' ORDER BY file_as');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateUserAccountOptions//

CREATE PROCEDURE generateUserAccountOptions()
BEGIN
	SELECT user_account_id, user_account_name 
    FROM user_account 
    ORDER BY user_account_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: NOTIFICATION SETTING
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveNotificationSetting//

CREATE PROCEDURE saveNotificationSetting(
    IN  p_notification_setting_id INT, 
    IN  p_notification_setting_name VARCHAR(100), 
    IN  p_notification_setting_description VARCHAR(200),
    IN  p_last_log_by INT
)
BEGIN
    DECLARE v_new_notification_setting_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_notification_setting_id IS NULL OR NOT EXISTS (SELECT 1 FROM notification_setting WHERE notification_setting_id = p_notification_setting_id) THEN
        INSERT INTO notification_setting (
            notification_setting_name, 
            notification_setting_description, 
            last_log_by
        ) VALUES (
            p_notification_setting_name, 
            p_notification_setting_description, 
            p_last_log_by
        );

        SET v_new_notification_setting_id = LAST_INSERT_ID();
    ELSE
        UPDATE notification_setting
        SET notification_setting_name           = p_notification_setting_name,
            notification_setting_description    = p_notification_setting_description,
            last_log_by                         = p_last_log_by
        WHERE notification_setting_id           = p_notification_setting_id;
        
        SET v_new_notification_setting_id = p_notification_setting_id;
    END IF;

    COMMIT;

    SELECT v_new_notification_setting_id AS new_notification_setting_id;
END //

DROP PROCEDURE IF EXISTS saveSystemNotificationTemplate//

CREATE PROCEDURE saveSystemNotificationTemplate(
    IN p_notification_setting_id INT, 
    IN p_system_notification_title VARCHAR(200),
    IN p_system_notification_message VARCHAR(200),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_notification_setting_id IS NULL OR NOT EXISTS (SELECT 1 FROM notification_setting_system_template WHERE notification_setting_id = p_notification_setting_id) THEN
        
        INSERT INTO notification_setting_system_template (
            notification_setting_id, 
            system_notification_title, 
            system_notification_message, 
            last_log_by
        ) VALUES (
            p_notification_setting_id, 
            p_system_notification_title, 
            p_system_notification_message, 
            p_last_log_by
        );

    ELSE
        UPDATE notification_setting_system_template
        SET system_notification_title       = p_system_notification_title,
            system_notification_message     = p_system_notification_message,
            last_log_by                     = p_last_log_by
        WHERE notification_setting_id       = p_notification_setting_id;
    END IF;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS saveEmailNotificationTemplate//

CREATE PROCEDURE saveEmailNotificationTemplate(
    IN p_notification_setting_id INT, 
    IN p_email_notification_subject VARCHAR(200),
    IN p_email_notification_body LONGTEXT,
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_notification_setting_id IS NULL 
       OR NOT EXISTS (SELECT 1 FROM notification_setting_email_template WHERE notification_setting_id = p_notification_setting_id) THEN
        
        INSERT INTO notification_setting_email_template (
            notification_setting_id, 
            email_notification_subject, 
            email_notification_body,
            last_log_by
        ) VALUES (
            p_notification_setting_id, 
            p_email_notification_subject, 
            p_email_notification_body,
            p_last_log_by
        );

    ELSE
        UPDATE notification_setting_email_template
        SET email_notification_subject  = p_email_notification_subject,
            email_notification_body     = p_email_notification_body,
            last_log_by                 = p_last_log_by
        WHERE notification_setting_id   = p_notification_setting_id;
    END IF;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS saveSMSNotificationTemplate//

CREATE PROCEDURE saveSMSNotificationTemplate(
    IN p_notification_setting_id INT, 
    IN p_sms_notification_message VARCHAR(500),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_notification_setting_id IS NULL 
       OR NOT EXISTS (SELECT 1 FROM notification_setting_sms_template WHERE notification_setting_id = p_notification_setting_id) THEN
        
        INSERT INTO notification_setting_sms_template (
            notification_setting_id, 
            sms_notification_message, 
            last_log_by
        ) VALUES (
            p_notification_setting_id, 
            p_sms_notification_message, 
            p_last_log_by
        );

    ELSE
        UPDATE notification_setting_sms_template
        SET sms_notification_message    = p_sms_notification_message,
            last_log_by                 = p_last_log_by
        WHERE notification_setting_id   = p_notification_setting_id;
    END IF;

    COMMIT;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateNotificationChannel//

CREATE PROCEDURE updateNotificationChannel(
    IN p_notification_setting_id INT, 
    IN p_notification_channel VARCHAR(10), 
    IN p_notification_channel_value TINYINT,
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_notification_channel = 'system' THEN
        UPDATE notification_setting
        SET system_notification         = p_notification_channel_value,
            last_log_by                 = p_last_log_by
        WHERE notification_setting_id   = p_notification_setting_id;

    ELSEIF p_notification_channel = 'email' THEN
        UPDATE notification_setting
        SET email_notification          = p_notification_channel_value,
            last_log_by                 = p_last_log_by
        WHERE notification_setting_id   = p_notification_setting_id;

    ELSE
        UPDATE notification_setting
        SET sms_notification            = p_notification_channel_value,
            last_log_by                 = p_last_log_by
        WHERE notification_setting_id   = p_notification_setting_id;
    END IF;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchNotificationSetting//

CREATE PROCEDURE fetchNotificationSetting(
    IN p_notification_setting_id INT
)
BEGIN
    SELECT * 
    FROM notification_setting
    WHERE notification_setting_id = p_notification_setting_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchEmailNotificationTemplate//

CREATE PROCEDURE fetchEmailNotificationTemplate(
    IN p_notification_setting_id INT
)
BEGIN
    SELECT * 
    FROM notification_setting_email_template
    WHERE notification_setting_id = p_notification_setting_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchSystemNotificationTemplate//

CREATE PROCEDURE fetchSystemNotificationTemplate(
    IN p_notification_setting_id INT
)
BEGIN
    SELECT * 
    FROM notification_setting_system_template
    WHERE notification_setting_id = p_notification_setting_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchSmsNotificationTemplate//

CREATE PROCEDURE fetchSmsNotificationTemplate(
    IN p_notification_setting_id INT
)
BEGIN
    SELECT * 
    FROM notification_setting_sms_template
    WHERE notification_setting_id = p_notification_setting_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteNotificationSetting//

CREATE PROCEDURE deleteNotificationSetting(
    IN p_notification_setting_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM notification_setting_email_template 
    WHERE notification_setting_id = p_notification_setting_id;

    DELETE FROM notification_setting_system_template
    WHERE notification_setting_id = p_notification_setting_id;

    DELETE FROM notification_setting_sms_template
    WHERE notification_setting_id = p_notification_setting_id;

    DELETE FROM notification_setting
    WHERE notification_setting_id = p_notification_setting_id; 
   
    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkNotificationSettingExist//

CREATE PROCEDURE checkNotificationSettingExist(
    IN p_notification_setting_id INT
)
BEGIN
    SELECT COUNT(*) AS total
    FROM notification_setting
    WHERE notification_setting_id = p_notification_setting_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateNotificationSettingTable//

CREATE PROCEDURE generateNotificationSettingTable()
BEGIN
    SELECT notification_setting_id, 
           notification_setting_name, 
           notification_setting_description
    FROM notification_setting 
    ORDER BY notification_setting_id;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: APP MODULE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveAppModule//

CREATE PROCEDURE saveAppModule(
    IN p_app_module_id INT, 
    IN p_app_module_name VARCHAR(100), 
    IN p_app_module_description VARCHAR(500), 
    IN p_menu_item_id INT, 
    IN p_menu_item_name VARCHAR(100), 
    IN p_order_sequence TINYINT(10), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_app_module_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_app_module_id IS NULL OR NOT EXISTS (SELECT 1 FROM app_module WHERE app_module_id = p_app_module_id) THEN
        INSERT INTO app_module (
            app_module_name,
            app_module_description,
            menu_item_id,
            menu_item_name,
            order_sequence,
            last_log_by
        ) 
        VALUES(
            p_app_module_name,
            p_app_module_description,
            p_menu_item_id, p_menu_item_name,
            p_order_sequence,
            p_last_log_by
        );
        
        SET v_new_app_module_id = LAST_INSERT_ID();
    ELSE
        UPDATE menu_item
        SET app_module_name = p_app_module_name,
            last_log_by = p_last_log_by
        WHERE app_module_id = p_app_module_id;

        UPDATE app_module
        SET app_module_name         = p_app_module_name,
            app_module_description  = p_app_module_description,
            menu_item_id            = p_menu_item_id,
            menu_item_name          = p_menu_item_name,
            order_sequence          = p_order_sequence,
            last_log_by             = p_last_log_by
        WHERE app_module_id         = p_app_module_id;
        
        SET v_new_app_module_id = p_app_module_id;
    END IF;

    COMMIT;

    SELECT v_new_app_module_id AS new_app_module_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateAppLogo//

CREATE PROCEDURE updateAppLogo(
	IN p_app_module_id INT, 
	IN p_app_logo VARCHAR(500), 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE app_module
    SET app_logo            = p_app_logo,
        last_log_by         = p_last_log_by
    WHERE app_module_id     = p_app_module_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchAppModule//

CREATE PROCEDURE fetchAppModule(
    IN p_app_module_id INT
)
BEGIN
	SELECT * FROM app_module
	WHERE app_module_id = p_app_module_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteAppModule//

CREATE PROCEDURE deleteAppModule(
    IN p_app_module_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM app_module
    WHERE app_module_id = p_app_module_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkAppModuleExist//

CREATE PROCEDURE checkAppModuleExist(
    IN p_app_module_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM app_module
    WHERE app_module_id = p_app_module_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateAppModuleTable//

CREATE PROCEDURE generateAppModuleTable()
BEGIN
	SELECT app_module_id, app_module_name, app_module_description, app_logo, order_sequence 
    FROM app_module 
    ORDER BY app_module_name;
END //

DROP PROCEDURE IF EXISTS generateAppModuleOptions//

CREATE PROCEDURE generateAppModuleOptions()
BEGIN
	SELECT app_module_id, app_module_name 
    FROM app_module 
    ORDER BY app_module_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: ROLE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveRole//

CREATE PROCEDURE saveRole(
    IN p_role_id INT,
    IN p_role_name VARCHAR(100),
    IN p_role_description VARCHAR(200),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_role_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_role_id IS NULL OR NOT EXISTS (SELECT 1 FROM role WHERE role_id = p_role_id) THEN
        INSERT INTO role (
            role_name,
            role_description,
            last_log_by
        ) 
	    VALUES(
            p_role_name,
            p_role_description,
            p_last_log_by
        );
        
        SET v_new_role_id = LAST_INSERT_ID();
    ELSE
        UPDATE role_permission
        SET role_name       = p_role_name,
            last_log_by     = p_last_log_by
        WHERE role_id       = p_role_id;

        UPDATE role_system_action_permission
        SET role_name       = p_role_name,
            last_log_by     = p_last_log_by
        WHERE role_id       = p_role_id;

        UPDATE role_user_account
        SET role_name       = p_role_name,
            last_log_by     = p_last_log_by
        WHERE role_id       = p_role_id;

        UPDATE role
        SET role_name           = p_role_name,
            role_name           = p_role_name,
            role_description    = p_role_description,
            last_log_by         = p_last_log_by
        WHERE role_id           = p_role_id;
        
        SET v_new_role_id = p_role_id;
    END IF;
    
    COMMIT;

    SELECT v_new_role_id AS new_role_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS insertRolePermission//

CREATE PROCEDURE insertRolePermission(
    IN p_role_id INT,
    IN p_role_name VARCHAR(100),
    IN p_menu_item_id INT,
    IN p_menu_item_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO role_permission (
        role_id,
        role_name,
        menu_item_id,
        menu_item_name,
        last_log_by
    ) 
	VALUES(
        p_role_id,
        p_role_name,
        p_menu_item_id,
        p_menu_item_name,
        p_last_log_by
    );

    COMMIT;
END //

DROP PROCEDURE IF EXISTS insertRoleSystemActionPermission//

CREATE PROCEDURE insertRoleSystemActionPermission(
    IN p_role_id INT,
    IN p_role_name VARCHAR(100),
    IN p_system_action_id INT,
    IN p_system_action_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO role_system_action_permission (
        role_id,
        role_name,
        system_action_id,
        system_action_name,
        last_log_by
    ) 
	VALUES(
        p_role_id, p_role_name,
        p_system_action_id,
        p_system_action_name,
        p_last_log_by
    );

    COMMIT;
END //

DROP PROCEDURE IF EXISTS insertRoleUserAccount//

CREATE PROCEDURE insertRoleUserAccount(
    IN p_role_id INT,
    IN p_role_name VARCHAR(100),
    IN p_user_account_id INT,
    IN p_file_as VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO role_user_account (
        role_id,
        role_name,
        user_account_id,
        file_as,
        last_log_by
    ) 
	VALUES(
        p_role_id,
        p_role_name,
        p_user_account_id,
        p_file_as, 
        p_last_log_by
    );

    COMMIT;
END //

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateRolePermission//

CREATE PROCEDURE updateRolePermission(
    IN p_role_permission_id INT,
    IN p_access_type VARCHAR(10),
    IN p_access TINYINT(1),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE role_permission
    SET 
        read_access             = CASE WHEN p_access_type = 'read'      THEN p_access ELSE read_access END,
        write_access            = CASE WHEN p_access_type = 'write'     THEN p_access ELSE write_access END,
        create_access           = CASE WHEN p_access_type = 'create'    THEN p_access ELSE create_access END,
        delete_access           = CASE WHEN p_access_type = 'delete'    THEN p_access ELSE delete_access END,
        import_access           = CASE WHEN p_access_type = 'import'    THEN p_access ELSE import_access END,
        export_access           = CASE WHEN p_access_type = 'export'    THEN p_access ELSE export_access END,
        log_notes_access        = CASE WHEN p_access_type = 'log notes' THEN p_access ELSE log_notes_access END,
        last_log_by             = p_last_log_by
    WHERE role_permission_id    = p_role_permission_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateRoleSystemActionPermission//

CREATE PROCEDURE updateRoleSystemActionPermission(
    IN p_role_system_action_permission_id INT,
    IN p_system_action_access TINYINT(1),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE role_system_action_permission
    SET system_action_access                = p_system_action_access,
        last_log_by                         = p_last_log_by
    WHERE role_system_action_permission_id  = p_role_system_action_permission_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchRole//

CREATE PROCEDURE fetchRole(
    IN p_role_id INT
)
BEGIN
	SELECT * FROM role
    WHERE role_id = p_role_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteRole//

CREATE PROCEDURE deleteRole(
    IN p_role_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM role_permission
    WHERE role_id = p_role_id;

    DELETE FROM role_system_action_permission
    WHERE role_id = p_role_id;

    DELETE FROM role_user_account
    WHERE role_id = p_role_id;

    DELETE FROM role
    WHERE role_id = p_role_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteRolePermission//

CREATE PROCEDURE deleteRolePermission(
    IN p_role_permission_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM role_permission
    WHERE role_permission_id = p_role_permission_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteRoleSystemActionPermission//

CREATE PROCEDURE deleteRoleSystemActionPermission(
    IN p_role_system_action_permission_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM role_system_action_permission
    WHERE role_system_action_permission_id = p_role_system_action_permission_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteRoleUserAccount//

CREATE PROCEDURE deleteRoleUserAccount(
    IN p_role_user_account_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM role_user_account
    WHERE role_user_account_id = p_role_user_account_id;
    
    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkRoleExist//

CREATE PROCEDURE checkRoleExist(
    IN p_role_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM role
    WHERE role_id = p_role_id;
END //

DROP PROCEDURE IF EXISTS checkRolePermissionExist//

CREATE PROCEDURE checkRolePermissionExist(
    IN p_role_permission_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM role_permission
    WHERE role_permission_id = p_role_permission_id;
END //

DROP PROCEDURE IF EXISTS checkRoleSystemActionPermissionExist//

CREATE PROCEDURE checkRoleSystemActionPermissionExist(
    IN p_role_system_action_permission_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM role_system_action_permission
    WHERE role_system_action_permission_id = p_role_system_action_permission_id;
END //

DROP PROCEDURE IF EXISTS checkRoleUserAccountExist//

CREATE PROCEDURE checkRoleUserAccountExist(
    IN p_role_user_account_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM role_user_account
    WHERE role_user_account_id = p_role_user_account_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateRoleTable//

CREATE PROCEDURE generateRoleTable()
BEGIN
	SELECT role_id, role_name, role_description
    FROM role 
    ORDER BY role_id;
END //

DROP PROCEDURE IF EXISTS generateRoleMenuItemPermissionTable//

CREATE PROCEDURE generateRoleMenuItemPermissionTable(
    IN p_role_id INT
)
BEGIN
	SELECT role_permission_id, menu_item_name, read_access, write_access, create_access, delete_access, import_access, export_access, log_notes_access
    FROM role_permission
    WHERE role_id = p_role_id
    ORDER BY menu_item_name;
END //

DROP PROCEDURE IF EXISTS generateRoleSystemActionPermissionTable//

CREATE PROCEDURE generateRoleSystemActionPermissionTable(
    IN p_role_id INT
)
BEGIN
	SELECT role_system_action_permission_id, system_action_name, system_action_access 
    FROM role_system_action_permission
    WHERE role_id = p_role_id
    ORDER BY system_action_name;
END //

DROP PROCEDURE IF EXISTS generateRoleUserAccountTable//

CREATE PROCEDURE generateRoleUserAccountTable(
    IN p_role_id INT
)
BEGIN
	SELECT role_user_account_id, user_account_id, file_as 
    FROM role_user_account
    WHERE role_id = p_role_id
    ORDER BY file_as;
END //

DROP PROCEDURE IF EXISTS generateUserAccountRoleList//

CREATE PROCEDURE generateUserAccountRoleList(
    IN p_user_account_id INT
)
BEGIN
	SELECT role_user_account_id, role_name, date_assigned
    FROM role_user_account
    WHERE user_account_id = p_user_account_id
    ORDER BY role_name;
END //

DROP PROCEDURE IF EXISTS generateRoleAssignedMenuItemTable//

CREATE PROCEDURE generateRoleAssignedMenuItemTable(
    IN p_role_id INT
)
BEGIN
    SELECT role_permission_id, menu_item_name, read_access, write_access, create_access, delete_access, import_access, export_access, log_notes_access 
    FROM role_permission
    WHERE role_id = p_role_id;
END //

DROP PROCEDURE IF EXISTS generateRoleAssignedSystemActionTable//

CREATE PROCEDURE generateRoleAssignedSystemActionTable(
    IN p_role_id INT
)
BEGIN
    SELECT role_system_action_permission_id, system_action_name, system_action_access 
    FROM role_system_action_permission
    WHERE role_id = p_role_id;
END //

DROP PROCEDURE IF EXISTS generateUserAccountRoleDualListBoxOptions//

CREATE PROCEDURE generateUserAccountRoleDualListBoxOptions(
    IN p_user_account_id INT
)
BEGIN
	SELECT role_id, role_name 
    FROM role 
    WHERE role_id NOT IN (SELECT role_id FROM role_user_account WHERE user_account_id = p_user_account_id)
    ORDER BY role_name;
END //

DROP PROCEDURE IF EXISTS generateSystemActionRoleDualListBoxOptions//

CREATE PROCEDURE generateSystemActionRoleDualListBoxOptions(
    IN p_system_action_id INT
)
BEGIN
	SELECT role_id, role_name 
    FROM role 
    WHERE role_id NOT IN (SELECT role_id FROM role_system_action_permission WHERE system_action_id = p_system_action_id)
    ORDER BY role_name;
END //

DROP PROCEDURE IF EXISTS generateRoleMenuItemDualListBoxOptions//

CREATE PROCEDURE generateRoleMenuItemDualListBoxOptions(
    IN p_role_id INT
)
BEGIN
	SELECT menu_item_id, menu_item_name 
    FROM menu_item 
    WHERE menu_item_id NOT IN (SELECT menu_item_id FROM role_permission WHERE role_id = p_role_id)
    ORDER BY menu_item_name;
END //

DROP PROCEDURE IF EXISTS generateRoleSystemActionDualListBoxOptions//

CREATE PROCEDURE generateRoleSystemActionDualListBoxOptions(
    IN p_role_id INT
)
BEGIN
	SELECT system_action_id, system_action_name 
    FROM system_action
    WHERE system_action_id NOT IN (SELECT system_action_id FROM role_system_action_permission WHERE role_id = p_role_id)
    ORDER BY system_action_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: MENU ITEM
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveMenuItem//

CREATE PROCEDURE saveMenuItem(
    IN p_menu_item_id INT, 
    IN p_menu_item_name VARCHAR(100), 
    IN p_menu_item_url VARCHAR(50), 
    IN p_menu_item_icon VARCHAR(50), 
    IN p_app_module_id INT, 
    IN p_app_module_name VARCHAR(100), 
    IN p_parent_id INT, 
    IN p_parent_name VARCHAR(100), 
    IN p_table_name VARCHAR(100), 
    IN p_order_sequence TINYINT(10), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_menu_item_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_menu_item_id IS NULL OR NOT EXISTS (SELECT 1 FROM menu_item WHERE menu_item_id = p_menu_item_id) THEN
        INSERT INTO menu_item (
            menu_item_name,
            menu_item_url,
            menu_item_icon,
            app_module_id,
            app_module_name,
            parent_id,
            parent_name,
            table_name,
            order_sequence,
            last_log_by
        ) 
        VALUES(
            p_menu_item_name,
            p_menu_item_url,
            p_menu_item_icon,
            p_app_module_id,
            p_app_module_name,
            p_parent_id,
            p_parent_name,
            p_table_name,
            p_order_sequence,
            p_last_log_by
        );
        
        SET v_new_menu_item_id = LAST_INSERT_ID();
    ELSE
        UPDATE role_permission
        SET menu_item_name  = p_menu_item_name,
            last_log_by     = p_last_log_by
        WHERE menu_item_id  = p_menu_item_id;
            
        UPDATE menu_item
        SET parent_name     = p_menu_item_name,
            last_log_by     = p_last_log_by
        WHERE parent_id     = p_menu_item_id;

        UPDATE menu_item
        SET menu_item_name      = p_menu_item_name,
            menu_item_url       = p_menu_item_url,
            menu_item_icon      = p_menu_item_icon,
            app_module_id       = p_app_module_id,
            app_module_name     = p_app_module_name,
            parent_id           = p_parent_id,
            parent_name         = p_parent_name,
            table_name          = p_table_name,
            order_sequence      = p_order_sequence,
            last_log_by         = p_last_log_by
        WHERE menu_item_id      = p_menu_item_id;
        
        SET v_new_menu_item_id = p_menu_item_id;
    END IF;

    COMMIT;

    SELECT v_new_menu_item_id AS new_menu_item_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchMenuItem//

CREATE PROCEDURE fetchMenuItem(
    IN p_menu_item_id INT
)
BEGIN
	SELECT * FROM menu_item
	WHERE menu_item_id = p_menu_item_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchBreadcrumb//

CREATE PROCEDURE fetchBreadcrumb(
    IN p_page_id INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_id INT DEFAULT p_page_id;
    
    DECLARE menu_name VARCHAR(100);
    DECLARE menu_url VARCHAR(50);
    DECLARE parent INT;
    
    DECLARE breadcrumb_cursor CURSOR FOR
        SELECT menu_item_name, menu_item_url, parent_id
        FROM menu_item
        WHERE menu_item_id = current_id;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS BreadcrumbTrail (
        menu_item_name VARCHAR(100),
        menu_item_url VARCHAR(50)
    );
    
    OPEN breadcrumb_cursor;
    
    read_loop: LOOP
        FETCH breadcrumb_cursor INTO menu_name, menu_url, parent;
        
        IF done THEN
            LEAVE read_loop;
        END IF;

        IF current_id != p_page_id THEN
            INSERT INTO BreadcrumbTrail (menu_item_name, menu_item_url) 
            VALUES (menu_name, menu_url);
        END IF;

        SET current_id = parent;
        
        IF current_id IS NULL THEN
            LEAVE read_loop;
        END IF;
        
        CLOSE breadcrumb_cursor;
        OPEN breadcrumb_cursor;
    END LOOP read_loop;

    CLOSE breadcrumb_cursor;

    SELECT * FROM BreadcrumbTrail ORDER BY FIELD(menu_item_name, menu_item_name);

    DROP TEMPORARY TABLE BreadcrumbTrail;
END //

DROP PROCEDURE IF EXISTS fetchNavBar//

CREATE PROCEDURE fetchNavBar(
    IN p_user_account_id INT,
    IN p_app_module_id INT
)
BEGIN
    SELECT 
    mi.menu_item_id,
    mi.menu_item_name,
    mi.menu_item_url,
    mi.parent_id,
    mi.app_module_id,
    mi.menu_item_icon,
    mi.order_sequence
    FROM menu_item AS mi
    INNER JOIN role_permission AS mar ON mi.menu_item_id = mar.menu_item_id
    INNER JOIN role_user_account AS ru ON mar.role_id = ru.role_id
    WHERE mar.read_access = 1 AND ru.user_account_id = p_user_account_id AND mi.app_module_id = p_app_module_id
    ORDER BY mi.order_sequence, mi.menu_item_name;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteMenuItem//

CREATE PROCEDURE deleteMenuItem(
    IN p_menu_item_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM role_permission
    WHERE menu_item_id = p_menu_item_id;

    DELETE FROM menu_item
    WHERE menu_item_id = p_menu_item_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkMenuItemExist//

CREATE PROCEDURE checkMenuItemExist(
    IN p_menu_item_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM menu_item
    WHERE menu_item_id = p_menu_item_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateMenuItemTable//

CREATE PROCEDURE generateMenuItemTable(
    IN p_filter_by_app_module TEXT,
    IN p_filter_by_parent_id TEXT
)
BEGIN
    DECLARE query TEXT DEFAULT 
        'SELECT menu_item_id, menu_item_name, app_module_name, parent_name, order_sequence
        FROM menu_item WHERE 1=1';

    IF p_filter_by_app_module IS NOT NULL AND p_filter_by_app_module <> '' THEN
        SET query = CONCAT(query, ' AND app_module_id IN (', p_filter_by_app_module, ')');
    END IF;

    IF p_filter_by_parent_id IS NOT NULL AND p_filter_by_parent_id <> '' THEN
        SET query = CONCAT(query, ' AND parent_id IN (', p_filter_by_parent_id, ')');
    END IF;

    SET query = CONCAT(query, ' ORDER BY menu_item_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateMenuItemAssignedRoleTable//

CREATE PROCEDURE generateMenuItemAssignedRoleTable(
    IN p_menu_item_id INT
)
BEGIN
    SELECT role_permission_id, role_name, read_access, write_access, create_access, delete_access, import_access, export_access, log_notes_access 
    FROM role_permission
    WHERE menu_item_id = p_menu_item_id;
END //

DROP PROCEDURE IF EXISTS generateMenuItemOptions//

CREATE PROCEDURE generateMenuItemOptions(
    IN p_menu_item_id INT
)
BEGIN
    IF p_menu_item_id IS NOT NULL AND p_menu_item_id != '' THEN
        SELECT menu_item_id, menu_item_name 
        FROM menu_item 
        WHERE menu_item_id != p_menu_item_id
        ORDER BY menu_item_name;
    ELSE
        SELECT menu_item_id, menu_item_name 
        FROM menu_item 
        ORDER BY menu_item_name;
    END IF;
END //

DROP PROCEDURE IF EXISTS generateMenuItemRoleDualListBoxOptions//

CREATE PROCEDURE generateMenuItemRoleDualListBoxOptions(
    IN p_menu_item_id INT
)
BEGIN
	SELECT role_id, role_name 
    FROM role 
    WHERE role_id NOT IN (SELECT role_id FROM role_permission WHERE menu_item_id = p_menu_item_id)
    ORDER BY role_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: SYSTEM ACTION
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveSystemAction//

CREATE PROCEDURE saveSystemAction(
    IN p_system_action_id INT, 
    IN p_system_action_name VARCHAR(100), 
    IN p_system_action_description VARCHAR(200),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_system_action_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_system_action_id IS NULL OR NOT EXISTS (SELECT 1 FROM system_action WHERE system_action_id = p_system_action_id) THEN
        INSERT INTO system_action (
            system_action_name,
            system_action_description,
            last_log_by
        ) 
        VALUES(
            p_system_action_name,
            p_system_action_description,
            p_last_log_by
        );
        
        SET v_new_system_action_id = LAST_INSERT_ID();
    ELSE
        UPDATE role_system_action_permission
        SET system_action_name  = p_system_action_name,
            last_log_by         = p_last_log_by
        WHERE system_action_id  = p_system_action_id;

        UPDATE system_action
        SET system_action_name          = p_system_action_name,
            system_action_description   = p_system_action_description,
            last_log_by                 = p_last_log_by
        WHERE system_action_id          = p_system_action_id;
        
        SET v_new_system_action_id = p_system_action_id;
    END IF;

    COMMIT;

    SELECT v_new_system_action_id AS new_system_action_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchSystemAction//

CREATE PROCEDURE fetchSystemAction(
    IN p_system_action_id INT
)
BEGIN
	SELECT * FROM system_action
	WHERE system_action_id = p_system_action_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteSystemAction//

CREATE PROCEDURE deleteSystemAction(
    IN p_system_action_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM role_system_action_permission
    WHERE system_action_id = p_system_action_id;
    
    DELETE FROM system_action
    WHERE system_action_id = p_system_action_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkSystemActionExist//

CREATE PROCEDURE checkSystemActionExist(
    IN p_system_action_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM system_action
    WHERE system_action_id = p_system_action_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateSystemActionTable//

CREATE PROCEDURE generateSystemActionTable()
BEGIN
    SELECT system_action_id, system_action_name, system_action_description 
    FROM system_action
    ORDER BY system_action_id;
END //

DROP PROCEDURE IF EXISTS generateSystemActionOptions//

CREATE PROCEDURE generateSystemActionOptions()
BEGIN
    SELECT system_action_id, system_action_name 
    FROM system_action 
    ORDER BY system_action_name;
END //

DROP PROCEDURE IF EXISTS generateSystemActionAssignedRoleTable//

CREATE PROCEDURE generateSystemActionAssignedRoleTable(
    IN p_system_action_id INT
)
BEGIN
    SELECT role_system_action_permission_id, role_name, system_action_access 
    FROM role_system_action_permission
    WHERE system_action_id = p_system_action_id;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: FILE TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveFileType//

CREATE PROCEDURE saveFileType(
    IN p_file_type_id INT, 
    IN p_file_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_file_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_file_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM file_type WHERE file_type_id = p_file_type_id) THEN
        INSERT INTO file_type (
            file_type_name,
            last_log_by
        ) 
        VALUES(
            p_file_type_name,
            p_last_log_by
        );
        
        SET v_new_file_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE file_extension
        SET file_type_name  = p_file_type_name,
            last_log_by     = p_last_log_by
        WHERE file_type_id  = p_file_type_id;

        UPDATE file_type
        SET file_type_name  = p_file_type_name,
            last_log_by     = p_last_log_by
        WHERE file_type_id  = p_file_type_id;
        
        SET v_new_file_type_id = p_file_type_id;
    END IF;

    COMMIT;

    SELECT v_new_file_type_id AS new_file_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchFileType//

CREATE PROCEDURE fetchFileType(
    IN p_file_type_id INT
)
BEGIN
	SELECT * FROM file_type
	WHERE file_type_id = p_file_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteFileType//

CREATE PROCEDURE deleteFileType(
    IN p_file_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM file_extension
    WHERE file_type_id = p_file_type_id;

    DELETE FROM file_type
    WHERE file_type_id = p_file_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkFileTypeExist//

CREATE PROCEDURE checkFileTypeExist(
    IN p_file_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM file_type
    WHERE file_type_id = p_file_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateFileTypeTable//

CREATE PROCEDURE generateFileTypeTable()
BEGIN
	SELECT file_type_id, file_type_name
    FROM file_type 
    ORDER BY file_type_id;
END //

DROP PROCEDURE IF EXISTS generateFileTypeOptions//

CREATE PROCEDURE generateFileTypeOptions()
BEGIN
	SELECT file_type_id, file_type_name 
    FROM file_type 
    ORDER BY file_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: FILE EXTENSION
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveFileExtension//

CREATE PROCEDURE saveFileExtension(
    IN p_file_extension_id INT, 
    IN p_file_extension_name VARCHAR(100), 
    IN p_file_extension VARCHAR(10), 
    IN p_file_type_id INT, 
    IN p_file_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_file_extension_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_file_extension_id IS NULL OR NOT EXISTS (SELECT 1 FROM file_extension WHERE file_extension_id = p_file_extension_id) THEN
        INSERT INTO file_extension (
            file_extension_name,
            file_extension,
            file_type_id,
            file_type_name,
            last_log_by
        ) 
        VALUES(
            p_file_extension_name,
            p_file_extension,
            p_file_type_id,
            p_file_type_name,
            p_last_log_by
        );
        
        SET v_new_file_extension_id = LAST_INSERT_ID();
    ELSE
        UPDATE upload_setting_file_extension
        SET file_extension_name     = p_file_extension_name,
            file_extension          = p_file_extension,
            last_log_by             = p_last_log_by
        WHERE file_extension_id     = p_file_extension_id;

        UPDATE file_extension
        SET file_extension_name     = p_file_extension_name,
            file_extension          = p_file_extension,
            file_type_id            = p_file_type_id,
            file_type_name          = p_file_type_name,
            last_log_by             = p_last_log_by
        WHERE file_extension_id     = p_file_extension_id;
        
        SET v_new_file_extension_id = p_file_extension_id;
    END IF;

    COMMIT;

    SELECT v_new_file_extension_id AS new_file_extension_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchFileExtension//

CREATE PROCEDURE fetchFileExtension(
    IN p_file_extension_id INT
)
BEGIN
	SELECT * FROM file_extension
	WHERE file_extension_id = p_file_extension_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteFileExtension//

CREATE PROCEDURE deleteFileExtension(
    IN p_file_extension_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM upload_setting_file_extension
    WHERE file_extension_id = p_file_extension_id;

    DELETE FROM file_extension
    WHERE file_extension_id = p_file_extension_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkFileExtensionExist//

CREATE PROCEDURE checkFileExtensionExist(
    IN p_file_extension_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM file_extension
    WHERE file_extension_id = p_file_extension_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateFileExtensionTable//

CREATE PROCEDURE generateFileExtensionTable(
    IN p_filter_by_file_type TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT file_extension_id, file_extension_name, file_extension, file_type_name 
                FROM file_extension ';

    IF p_filter_by_file_type IS NOT NULL AND p_filter_by_file_type <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' file_type_id IN (', p_filter_by_file_type, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY file_extension_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateFileExtensionOptions//

CREATE PROCEDURE generateFileExtensionOptions()
BEGIN
	SELECT file_extension_id, file_extension_name, file_extension
    FROM file_extension 
    ORDER BY file_extension_name;
END //

DROP PROCEDURE IF EXISTS generateFileExtensionDualListBoxOptions//

CREATE PROCEDURE generateFileExtensionDualListBoxOptions(
    IN p_upload_setting_id INT
)
BEGIN
	SELECT file_extension_id, file_extension_name, file_extension
    FROM file_extension 
    WHERE file_extension_id NOT IN (SELECT file_extension_id FROM upload_setting_file_extension WHERE upload_setting_id = p_upload_setting_id)
    ORDER BY file_extension_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: UPLOAD SETTING
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveUploadSetting//

CREATE PROCEDURE saveUploadSetting(
    IN p_upload_setting_id INT, 
    IN p_upload_setting_name VARCHAR(100), 
    IN p_upload_setting_description VARCHAR(200), 
    IN p_max_file_size DOUBLE, 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_upload_setting_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_upload_setting_id IS NULL OR NOT EXISTS (SELECT 1 FROM upload_setting WHERE upload_setting_id = p_upload_setting_id) THEN
        INSERT INTO upload_setting (
            upload_setting_name,
            upload_setting_description,
            max_file_size,
            last_log_by
        ) 
        VALUES(
            p_upload_setting_name,
            p_upload_setting_description,
            p_max_file_size,
            p_last_log_by
        );
        
        SET v_new_upload_setting_id = LAST_INSERT_ID();
    ELSE
        UPDATE upload_setting_file_extension
        SET upload_setting_name     = p_upload_setting_name,
            last_log_by             = p_last_log_by
        WHERE upload_setting_id     = p_upload_setting_id;

        UPDATE upload_setting
        SET upload_setting_name         = p_upload_setting_name,
            upload_setting_description  = p_upload_setting_description,
            max_file_size               = p_max_file_size,
            last_log_by                 = p_last_log_by
        WHERE upload_setting_id         = p_upload_setting_id;
        
        SET v_new_upload_setting_id = p_upload_setting_id;
    END IF;

    COMMIT;

    SELECT v_new_upload_setting_id AS new_upload_setting_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchUploadSetting//

CREATE PROCEDURE fetchUploadSetting(
	IN p_upload_setting_id INT
)
BEGIN
	SELECT * FROM upload_setting
	WHERE upload_setting_id = p_upload_setting_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteUploadSetting//

CREATE PROCEDURE deleteUploadSetting(
    IN p_upload_setting_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM upload_setting_file_extension
    WHERE upload_setting_id = p_upload_setting_id;

    DELETE FROM upload_setting
    WHERE upload_setting_id = p_upload_setting_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkUploadSettingExist//

CREATE PROCEDURE checkUploadSettingExist(
    IN p_upload_setting_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM upload_setting
    WHERE upload_setting_id = p_upload_setting_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateUploadSettingTable//

CREATE PROCEDURE generateUploadSettingTable()
BEGIN
	SELECT upload_setting_id, upload_setting_name, upload_setting_description, max_file_size
    FROM upload_setting 
    ORDER BY upload_setting_id;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: UPLOAD SETTING FILE EXTENSION
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS insertUploadSettingFileExtension//

CREATE PROCEDURE insertUploadSettingFileExtension(
    IN p_upload_setting_id INT, 
    IN p_upload_setting_name VARCHAR(100), 
    IN p_file_extension_id INT, 
    IN p_file_extension_name VARCHAR(100), 
    IN p_file_extension VARCHAR(10), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO upload_setting_file_extension (
        upload_setting_id,
        upload_setting_name,
        file_extension_id,
        file_extension_name,
        file_extension,
        last_log_by
    ) 
    VALUES(
        p_upload_setting_id,
        p_upload_setting_name,
        p_file_extension_id,
        p_file_extension_name,
        p_file_extension,
        p_last_log_by
    );

    COMMIT;
END //

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchUploadSettingFileExtension//

CREATE PROCEDURE fetchUploadSettingFileExtension(
	IN p_upload_setting_id INT
)
BEGIN
	SELECT * FROM upload_setting_file_extension
	WHERE upload_setting_id = p_upload_setting_id;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteUploadSettingFileExtension//

CREATE PROCEDURE deleteUploadSettingFileExtension(
    IN p_upload_setting_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM upload_setting_file_extension 
    WHERE upload_setting_id = p_upload_setting_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateUploadSettingFileExtensionList//

CREATE PROCEDURE generateUploadSettingFileExtensionList(
    IN p_upload_setting_id INT
)
BEGIN
	SELECT upload_setting_file_extension_id, file_extension_id, file_extension_name, file_extension
    FROM upload_setting_file_extension
    WHERE upload_setting_id = p_upload_setting_id
    ORDER BY file_extension_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: EXPORT
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchExportData//

CREATE PROCEDURE fetchExportData(
    IN p_table_name VARCHAR(255),
    IN p_columns TEXT,
    IN p_ids TEXT
)
BEGIN
    SET @sql = CONCAT('SELECT ', p_columns, ' FROM ', p_table_name, ' WHERE ', p_table_name, '_id IN (', p_ids, ')');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END//

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateTableOptions//

CREATE PROCEDURE generateTableOptions(
    IN p_database_name VARCHAR(255)
)
BEGIN
	SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = p_database_name;
END //

DROP PROCEDURE IF EXISTS generateExportOptions//

CREATE PROCEDURE generateExportOptions(
    IN p_databasename VARCHAR(500),
    IN p_table_name VARCHAR(500)
)
BEGIN
    SELECT column_name 
    FROM information_schema.columns 
    WHERE table_schema = p_databasename 
    AND table_name = p_table_name
    ORDER BY ordinal_position;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */


/* =============================================================================================
   STORED PROCEDURE: IMPORT
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveImport//

CREATE PROCEDURE saveImport(
    IN p_table_name VARCHAR(255),
    IN p_columns TEXT,
    IN p_placeholders TEXT,
    IN p_updateFields TEXT,
    IN p_values TEXT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @p1 = MESSAGE_TEXT;
            SELECT @p1 AS error_message;
        ROLLBACK;
    END;

    START TRANSACTION;

    SET @sql = CONCAT(
        'INSERT INTO ', p_table_name, ' (', p_columns, ') ',
        'VALUES ', p_values, ' ',
        'ON DUPLICATE KEY UPDATE ', p_updateFields
    );

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    COMMIT;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: COUNTRY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveCountry//

CREATE PROCEDURE saveCountry(
    IN p_country_id INT, 
    IN p_country_name VARCHAR(100), 
    IN p_country_code VARCHAR(10),
    IN p_phone_code VARCHAR(10),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_country_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_country_id IS NULL OR NOT EXISTS (SELECT 1 FROM country WHERE country_id = p_country_id) THEN
        INSERT INTO country (
            country_name,
            country_code,
            phone_code,
            last_log_by
        ) 
        VALUES(
            p_country_name,
            p_country_code,
            p_phone_code,
            p_last_log_by
        );
        
        SET v_new_country_id = LAST_INSERT_ID();
    ELSE
        UPDATE state
        SET country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE country_id    = p_country_id;

        UPDATE city
        SET country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE country_id    = p_country_id;

        UPDATE company
        SET country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE country_id    = p_country_id;

        UPDATE work_location
        SET country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE country_id    = p_country_id;

        UPDATE supplier
        SET country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE country_id    = p_country_id;

        UPDATE warehouse
        SET country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE country_id    = p_country_id;

        UPDATE employee
        SET private_address_country_name    = p_country_name,
            last_log_by                     = p_last_log_by
        WHERE private_address_country_id    = p_country_id;
        
        UPDATE country
        SET country_name    = p_country_name,
            country_code    = p_country_code,
            phone_code      = p_phone_code,
            last_log_by     = p_last_log_by
        WHERE country_id    = p_country_id;

         SET v_new_country_id = p_country_id;
    END IF;

    COMMIT;

    SELECT v_new_country_id AS new_country_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchCountry//

CREATE PROCEDURE fetchCountry(
    IN p_country_id INT
)
BEGIN
	SELECT * FROM country
	WHERE country_id = p_country_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteCountry//

CREATE PROCEDURE deleteCountry(
    IN p_country_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM state
    WHERE country_id = p_country_id;

    DELETE FROM city
    WHERE country_id = p_country_id;

    DELETE FROM country
    WHERE country_id = p_country_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkCountryExist//

CREATE PROCEDURE checkCountryExist(
    IN p_country_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM country
    WHERE country_id = p_country_id;
END //


/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateCountryTable//

CREATE PROCEDURE generateCountryTable()
BEGIN
    SELECT country_id, country_name, country_code, phone_code 
    FROM country
    ORDER BY country_id;
END //

DROP PROCEDURE IF EXISTS generateCountryOptions//

CREATE PROCEDURE generateCountryOptions()
BEGIN
    SELECT country_id, country_name 
    FROM country 
    ORDER BY country_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: STATE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveState//

CREATE PROCEDURE saveState(
    IN p_state_id INT, 
    IN p_state_name VARCHAR(100), 
    IN p_country_id INT,
    IN p_country_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_state_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_state_id IS NULL OR NOT EXISTS (SELECT 1 FROM state WHERE state_id = p_state_id) THEN
        INSERT INTO state (
            state_name,
            country_id,
            country_name,
            last_log_by
        ) 
        VALUES(
            p_state_name,
            p_country_id,
            p_country_name,
            p_last_log_by
        );
        
       SET v_new_state_id = LAST_INSERT_ID();
    ELSE
        UPDATE city
        SET state_name      = p_state_name,
            last_log_by     = p_last_log_by
        WHERE state_id      = p_state_id;

        UPDATE company
        SET state_name      = p_state_name,
            last_log_by     = p_last_log_by
        WHERE state_id      = p_state_id;

        UPDATE work_location
        SET state_name      = p_state_name,
            last_log_by     = p_last_log_by
        WHERE state_id      = p_state_id;

        UPDATE supplier
        SET state_name      = p_state_name,
            last_log_by     = p_last_log_by
        WHERE state_id      = p_state_id;

        UPDATE warehouse
        SET state_name      = p_state_name,
            last_log_by     = p_last_log_by
        WHERE state_id      = p_state_id;

        UPDATE employee
        SET private_address_state_name  = p_state_name,
            last_log_by                 = p_last_log_by
        WHERE private_address_state_id  = p_state_id;
        
        UPDATE state
        SET state_name      = p_state_name,
            country_id      = p_country_id,
            country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE state_id      = p_state_id;

        SET v_new_state_id = p_state_id;
    END IF;

    COMMIT;

    SELECT v_new_state_id AS new_state_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchState//

CREATE PROCEDURE fetchState(
    IN p_state_id INT
)
BEGIN
	SELECT * FROM state
	WHERE state_id = p_state_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteState//

CREATE PROCEDURE deleteState(
    IN p_state_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM city WHERE state_id = p_state_id;
    DELETE FROM state WHERE state_id = p_state_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkStateExist//

CREATE PROCEDURE checkStateExist(
    IN p_state_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM state
    WHERE state_id = p_state_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateStateTable//

CREATE PROCEDURE generateStateTable(
    IN p_filter_by_country TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT state_id, state_name, country_name 
                FROM state ';

    IF p_filter_by_country IS NOT NULL AND p_filter_by_country <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' country_id IN (', p_filter_by_country, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY state_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateStateOptions//

CREATE PROCEDURE generateStateOptions()
BEGIN
    SELECT state_id, state_name 
    FROM state 
    ORDER BY state_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: CITY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveCity//

CREATE PROCEDURE saveCity(
    IN p_city_id INT, 
    IN p_city_name VARCHAR(100), 
    IN p_state_id INT,
    IN p_state_name VARCHAR(100),
    IN p_country_id INT,
    IN p_country_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_city_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_city_id IS NULL OR NOT EXISTS (SELECT 1 FROM city WHERE city_id = p_city_id) THEN
        INSERT INTO city (
            city_name,
            state_id,
            state_name,
            country_id,
            country_name,
            last_log_by
        ) 
        VALUES(
            p_city_name,
            p_state_id,
            p_state_name,
            p_country_id,
            p_country_name,
            p_last_log_by
        );
        
        SET v_new_city_id = LAST_INSERT_ID();
    ELSE
        UPDATE work_location
        SET city_name       = p_city_name,
            last_log_by     = p_last_log_by
        WHERE city_id       = p_city_id;

        UPDATE company
        SET city_name       = p_city_name,
            last_log_by     = p_last_log_by
        WHERE city_id       = p_city_id;

        UPDATE warehouse
        SET city_name       = p_city_name,
            last_log_by     = p_last_log_by
        WHERE city_id       = p_city_id;

        UPDATE supplier
        SET city_name       = p_city_name,
            last_log_by     = p_last_log_by
        WHERE city_id       = p_city_id;

        UPDATE employee
        SET private_address_city_name       = p_city_name,
            last_log_by                     = p_last_log_by
        WHERE private_address_city_id       = p_city_id;

        UPDATE city
        SET city_name       = p_city_name,
            state_id        = p_state_id,
            state_name      = p_state_name,
            country_id      = p_country_id,
            country_name    = p_country_name,
            last_log_by     = p_last_log_by
        WHERE city_id       = p_city_id;

        SET v_new_city_id = p_city_id;
    END IF;

    COMMIT;

    SELECT v_new_city_id AS new_city_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchCity//

CREATE PROCEDURE fetchCity(
    IN p_city_id INT
)
BEGIN
	SELECT * FROM city
	WHERE city_id = p_city_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteCity//

CREATE PROCEDURE deleteCity(
    IN p_city_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM city WHERE city_id = p_city_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkCityExist//

CREATE PROCEDURE checkCityExist(
    IN p_city_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM city
    WHERE city_id = p_city_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateCityTable//

CREATE PROCEDURE generateCityTable(
    IN p_filter_by_state TEXT,
    IN p_filter_by_country TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT city_id, city_name, state_name, country_name 
                FROM city ';

    IF p_filter_by_state IS NOT NULL AND p_filter_by_state <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' state_id IN (', p_filter_by_state, ')');
    END IF;

    IF p_filter_by_country IS NOT NULL AND p_filter_by_country <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' country_id IN (', p_filter_by_country, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY city_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateCityOptions//

CREATE PROCEDURE generateCityOptions()
BEGIN
    SELECT city_id, city_name, state_name, country_name
    FROM city 
    ORDER BY city_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: CURRENCY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveCurrency//

CREATE PROCEDURE saveCurrency(
    IN p_currency_id INT, 
    IN p_currency_name VARCHAR(100), 
    IN p_symbol VARCHAR(5),
    IN p_shorthand VARCHAR(10),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_currency_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_currency_id IS NULL OR NOT EXISTS (SELECT 1 FROM currency WHERE currency_id = p_currency_id) THEN
        INSERT INTO currency (
            currency_name,
            symbol,
            shorthand,
            last_log_by
        ) 
        VALUES(
            p_currency_name,
            p_symbol,
            p_shorthand,
            p_last_log_by
        );
        
        SET v_new_currency_id = LAST_INSERT_ID();
    ELSE        
        UPDATE company
        SET currency_name   = p_currency_name,
            last_log_by     = p_last_log_by
        WHERE currency_id   = p_currency_id;

        UPDATE currency
        SET currency_name   = p_currency_name,
            symbol          = p_symbol,
            shorthand       = p_shorthand,
            last_log_by     = p_last_log_by
        WHERE currency_id   = p_currency_id;

        SET v_new_currency_id = p_currency_id;
    END IF;

    COMMIT;

    SELECT v_new_currency_id AS new_currency_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchCurrency//

CREATE PROCEDURE fetchCurrency(
    IN p_currency_id INT
)
BEGIN
	SELECT * FROM currency
	WHERE currency_id = p_currency_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteCurrency//

CREATE PROCEDURE deleteCurrency(
    IN p_currency_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM currency WHERE currency_id = p_currency_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkCurrencyExist//

CREATE PROCEDURE checkCurrencyExist(
    IN p_currency_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM currency
    WHERE currency_id = p_currency_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateCurrencyTable//

CREATE PROCEDURE generateCurrencyTable()
BEGIN
    SELECT currency_id, currency_name, symbol, shorthand 
    FROM currency
    ORDER BY currency_id;
END //

DROP PROCEDURE IF EXISTS generateCurrencyOptions//

CREATE PROCEDURE generateCurrencyOptions()
BEGIN
    SELECT currency_id, currency_name, symbol
    FROM currency 
    ORDER BY currency_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: NATIONALITY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveNationality//

CREATE PROCEDURE saveNationality(
    IN p_nationality_id INT, 
    IN p_nationality_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_nationality_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_nationality_id IS NULL OR NOT EXISTS (SELECT 1 FROM nationality WHERE nationality_id = p_nationality_id) THEN
        INSERT INTO nationality (
            nationality_name,
            last_log_by
        ) 
        VALUES(
            p_nationality_name,
            p_last_log_by
        );
        
        SET v_new_nationality_id = LAST_INSERT_ID();
    ELSE        
        UPDATE employee
        SET nationality_name    = p_nationality_name,
            last_log_by         = p_last_log_by
        WHERE nationality_id    = p_nationality_id;

        UPDATE nationality
        SET nationality_name    = p_nationality_name,
            last_log_by         = p_last_log_by
        WHERE nationality_id    = p_nationality_id;

        SET v_new_nationality_id = p_nationality_id;
    END IF;

    COMMIT;

    SELECT v_new_nationality_id AS new_nationality_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchNationality//

CREATE PROCEDURE fetchNationality(
    IN p_nationality_id INT
)
BEGIN
	SELECT * FROM nationality
	WHERE nationality_id = p_nationality_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteNationality//

CREATE PROCEDURE deleteNationality(
    IN p_nationality_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM nationality WHERE nationality_id = p_nationality_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkNationalityExist//

CREATE PROCEDURE checkNationalityExist(
    IN p_nationality_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM nationality
    WHERE nationality_id = p_nationality_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateNationalityTable//

CREATE PROCEDURE generateNationalityTable()
BEGIN
	SELECT nationality_id, nationality_name
    FROM nationality 
    ORDER BY nationality_id;
END //

DROP PROCEDURE IF EXISTS generateNationalityOptions//

CREATE PROCEDURE generateNationalityOptions()
BEGIN
	SELECT nationality_id, nationality_name 
    FROM nationality 
    ORDER BY nationality_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: COMPANY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveCompany//

CREATE PROCEDURE saveCompany(
    IN p_company_id INT, 
    IN p_company_name VARCHAR(100), 
    IN p_address VARCHAR(1000), 
    IN p_city_id INT, 
    IN p_city_name VARCHAR(100), 
    IN p_state_id INT, 
    IN p_state_name VARCHAR(100), 
    IN p_country_id INT, 
    IN p_country_name VARCHAR(100), 
    IN p_tax_id VARCHAR(100), 
    IN p_currency_id INT, 
    IN p_currency_name VARCHAR(100), 
    IN p_phone VARCHAR(20), 
    IN p_telephone VARCHAR(20), 
    IN p_email VARCHAR(255), 
    IN p_website VARCHAR(255), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_company_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_company_id IS NULL OR NOT EXISTS (SELECT 1 FROM company WHERE company_id = p_company_id) THEN
        INSERT INTO company (
            company_name,
            address,
            city_id,
            city_name,
            state_id,
            state_name,
            country_id,
            country_name,
            tax_id,
            currency_id,
            currency_name,
            phone,
            telephone,
            email,
            website,
            last_log_by
        ) 
        VALUES(
            p_company_name,
            p_address,
            p_city_id,
            p_city_name,
            p_state_id,
            p_state_name,
            p_country_id,
            p_country_name,
            p_tax_id,
            p_currency_id,
            p_currency_name,
            p_phone,
            p_telephone,
            p_email,
            p_website,
            p_last_log_by
        );
        
        SET v_new_company_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET company_name    = p_company_name,
            last_log_by     = p_last_log_by
        WHERE company_id    = p_company_id;
        
        UPDATE company
        SET company_name    = p_company_name,
            address         = p_address,
            city_id         = p_city_id,
            city_name       = p_city_name,
            state_id        = p_state_id,
            state_name      = p_state_name,
            country_id      = p_country_id,
            country_name    = p_country_name,
            tax_id          = p_tax_id,
            currency_id     = p_currency_id,
            currency_name   = p_currency_name,
            phone           = p_phone,
            telephone       = p_telephone,
            email           = p_email,
            website         = p_website,
            last_log_by     = p_last_log_by
        WHERE company_id    = p_company_id;

        SET v_new_company_id = p_company_id;
    END IF;

    COMMIT;

    SELECT v_new_company_id AS new_company_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateCompanyLogo//

CREATE PROCEDURE updateCompanyLogo(
	IN p_company_id INT, 
	IN p_company_logo VARCHAR(500), 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE company
    SET company_logo    = p_company_logo,
        last_log_by     = p_last_log_by
    WHERE company_id    = p_company_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchCompany//

CREATE PROCEDURE fetchCompany(
    IN p_company_id INT
)
BEGIN
	SELECT * FROM company
	WHERE company_id = p_company_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteCompany//

CREATE PROCEDURE deleteCompany(
    IN p_company_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM company WHERE company_id = p_company_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkCompanyExist//

CREATE PROCEDURE checkCompanyExist(
    IN p_company_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM company
    WHERE company_id = p_company_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateCompanyTable//

CREATE PROCEDURE generateCompanyTable(
    IN p_filter_by_city TEXT,
    IN p_filter_by_state TEXT,
    IN p_filter_by_country TEXT,
    IN p_filter_by_currency TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT company_id, company_name, company_logo, address, city_name, state_name, country_name 
                FROM company ';

    IF p_filter_by_city IS NOT NULL AND p_filter_by_city <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' city_id IN (', p_filter_by_city, ')');
    END IF;

    IF p_filter_by_state IS NOT NULL AND p_filter_by_state <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' state_id IN (', p_filter_by_state, ')');
    END IF;

    IF p_filter_by_country IS NOT NULL AND p_filter_by_country <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' country_id IN (', p_filter_by_country, ')');
    END IF;

    IF p_filter_by_currency IS NOT NULL AND p_filter_by_currency <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' currency_id IN (', p_filter_by_currency, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY company_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateCompanyOptions//

CREATE PROCEDURE generateCompanyOptions()
BEGIN
	SELECT company_id, company_name 
    FROM company 
    ORDER BY company_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: BLOOD TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveBloodType//

CREATE PROCEDURE saveBloodType(
    IN p_blood_type_id INT, 
    IN p_blood_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_blood_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_blood_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM blood_type WHERE blood_type_id = p_blood_type_id) THEN
        INSERT INTO blood_type (
            blood_type_name,
            last_log_by
        ) 
        VALUES(
            p_blood_type_name,
            p_last_log_by
        );
        
        SET v_new_blood_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET blood_type_name     = p_blood_type_name,
            last_log_by         = p_last_log_by
        WHERE blood_type_id     = p_blood_type_id;

        UPDATE blood_type
        SET blood_type_name     = p_blood_type_name,
            last_log_by         = p_last_log_by
        WHERE blood_type_id     = p_blood_type_id;

        SET v_new_blood_type_id = p_blood_type_id;
    END IF;

    COMMIT;

    SELECT v_new_blood_type_id AS new_blood_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchBloodType//

CREATE PROCEDURE fetchBloodType(
    IN p_blood_type_id INT
)
BEGIN
	SELECT * FROM blood_type
	WHERE blood_type_id = p_blood_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteBloodType//

CREATE PROCEDURE deleteBloodType(
    IN p_blood_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM blood_type WHERE blood_type_id = p_blood_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkBloodTypeExist//

CREATE PROCEDURE checkBloodTypeExist(
    IN p_blood_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM blood_type
    WHERE blood_type_id = p_blood_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateBloodTypeTable//

CREATE PROCEDURE generateBloodTypeTable()
BEGIN
	SELECT blood_type_id, blood_type_name
    FROM blood_type 
    ORDER BY blood_type_id;
END //

DROP PROCEDURE IF EXISTS generateBloodTypeOptions//

CREATE PROCEDURE generateBloodTypeOptions()
BEGIN
	SELECT blood_type_id, blood_type_name 
    FROM blood_type 
    ORDER BY blood_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: CIVIL STATUS
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveCivilStatus//

CREATE PROCEDURE saveCivilStatus(
    IN p_civil_status_id INT, 
    IN p_civil_status_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_civil_status_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_civil_status_id IS NULL OR NOT EXISTS (SELECT 1 FROM civil_status WHERE civil_status_id = p_civil_status_id) THEN
        INSERT INTO civil_status (
            civil_status_name,
            last_log_by
        ) 
        VALUES(
            p_civil_status_name,
            p_last_log_by
        );
        
        SET v_new_civil_status_id = LAST_INSERT_ID();
    ELSE
        UPDATE civil_status
        SET civil_status_name   = p_civil_status_name,
            last_log_by         = p_last_log_by
        WHERE civil_status_id   = p_civil_status_id;

        UPDATE employee
        SET civil_status_name   = p_civil_status_name,
            last_log_by         = p_last_log_by
        WHERE civil_status_id   = p_civil_status_id;

        SET v_new_civil_status_id = p_civil_status_id;
    END IF;

    COMMIT;

    SELECT v_new_civil_status_id AS new_civil_status_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchCivilStatus//

CREATE PROCEDURE fetchCivilStatus(
    IN p_civil_status_id INT
)
BEGIN
	SELECT * FROM civil_status
	WHERE civil_status_id = p_civil_status_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteCivilStatus//

CREATE PROCEDURE deleteCivilStatus(
    IN p_civil_status_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM civil_status WHERE civil_status_id = p_civil_status_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkCivilStatusExist//

CREATE PROCEDURE checkCivilStatusExist(
    IN p_civil_status_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM civil_status
    WHERE civil_status_id = p_civil_status_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateCivilStatusTable//

CREATE PROCEDURE generateCivilStatusTable()
BEGIN
	SELECT civil_status_id, civil_status_name
    FROM civil_status 
    ORDER BY civil_status_id;
END //

DROP PROCEDURE IF EXISTS generateCivilStatusOptions//

CREATE PROCEDURE generateCivilStatusOptions()
BEGIN
	SELECT civil_status_id, civil_status_name 
    FROM civil_status 
    ORDER BY civil_status_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: CREDENTIAL TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveCredentialType//

CREATE PROCEDURE saveCredentialType(
    IN p_credential_type_id INT, 
    IN p_credential_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_credential_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_credential_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM credential_type WHERE credential_type_id = p_credential_type_id) THEN
        INSERT INTO credential_type (
            credential_type_name,
            last_log_by
        ) 
        VALUES(
            p_credential_type_name,
            p_last_log_by
        );
        
        SET v_new_credential_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE credential_type
        SET credential_type_name    = p_credential_type_name,
            last_log_by             = p_last_log_by
        WHERE credential_type_id    = p_credential_type_id;

        SET v_new_credential_type_id = p_credential_type_id;
    END IF;

    COMMIT;

    SELECT v_new_credential_type_id AS new_credential_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchCredentialType//

CREATE PROCEDURE fetchCredentialType(
    IN p_credential_type_id INT
)
BEGIN
	SELECT * FROM credential_type
	WHERE credential_type_id = p_credential_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteCredentialType//

CREATE PROCEDURE deleteCredentialType(
    IN p_credential_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM credential_type WHERE credential_type_id = p_credential_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkCredentialTypeExist//

CREATE PROCEDURE checkCredentialTypeExist(
    IN p_credential_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM credential_type
    WHERE credential_type_id = p_credential_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateCredentialTypeTable//

CREATE PROCEDURE generateCredentialTypeTable()
BEGIN
	SELECT credential_type_id, credential_type_name
    FROM credential_type 
    ORDER BY credential_type_id;
END //

DROP PROCEDURE IF EXISTS generateCredentialTypeOptions//

CREATE PROCEDURE generateCredentialTypeOptions()
BEGIN
	SELECT credential_type_id, credential_type_name 
    FROM credential_type 
    ORDER BY credential_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: EDUCATIONAL STAGE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveEducationalStage//

CREATE PROCEDURE saveEducationalStage(
    IN p_educational_stage_id INT, 
    IN p_educational_stage_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_educational_stage_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_educational_stage_id IS NULL OR NOT EXISTS (SELECT 1 FROM educational_stage WHERE educational_stage_id = p_educational_stage_id) THEN
        INSERT INTO educational_stage (
            educational_stage_name,
            last_log_by
        ) 
        VALUES(
            p_educational_stage_name,
            p_last_log_by
        );
        
        SET v_new_educational_stage_id = LAST_INSERT_ID();
    ELSE
        UPDATE educational_stage
        SET educational_stage_name  = p_educational_stage_name,
            last_log_by             = p_last_log_by
        WHERE educational_stage_id  = p_educational_stage_id;

        SET v_new_educational_stage_id = p_educational_stage_id;
    END IF;

    COMMIT;

    SELECT v_new_educational_stage_id AS new_educational_stage_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchEducationalStage//

CREATE PROCEDURE fetchEducationalStage(
    IN p_educational_stage_id INT
)
BEGIN
	SELECT * FROM educational_stage
	WHERE educational_stage_id = p_educational_stage_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteEducationalStage//

CREATE PROCEDURE deleteEducationalStage(
    IN p_educational_stage_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM educational_stage WHERE educational_stage_id = p_educational_stage_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkEducationalStageExist//

CREATE PROCEDURE checkEducationalStageExist(
    IN p_educational_stage_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM educational_stage
    WHERE educational_stage_id = p_educational_stage_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateEducationalStageTable//

CREATE PROCEDURE generateEducationalStageTable()
BEGIN
	SELECT educational_stage_id, educational_stage_name
    FROM educational_stage 
    ORDER BY educational_stage_id;
END //

DROP PROCEDURE IF EXISTS generateEducationalStageOptions//

CREATE PROCEDURE generateEducationalStageOptions()
BEGIN
	SELECT educational_stage_id, educational_stage_name 
    FROM educational_stage 
    ORDER BY educational_stage_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: GENDER
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveGender//

CREATE PROCEDURE saveGender(
    IN p_gender_id INT, 
    IN p_gender_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_gender_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_gender_id IS NULL OR NOT EXISTS (SELECT 1 FROM gender WHERE gender_id = p_gender_id) THEN
        INSERT INTO gender (
            gender_name,
            last_log_by
        ) 
        VALUES(
            p_gender_name,
            p_last_log_by
        );
        
        SET v_new_gender_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET gender_name     = p_gender_name,
            last_log_by     = p_last_log_by
        WHERE gender_id     = p_gender_id;

        UPDATE gender
        SET gender_name     = p_gender_name,
            last_log_by     = p_last_log_by
        WHERE gender_id     = p_gender_id;

        SET v_new_gender_id = p_gender_id;
    END IF;

    COMMIT;

    SELECT v_new_gender_id AS new_gender_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchGender//

CREATE PROCEDURE fetchGender(
    IN p_gender_id INT
)
BEGIN
	SELECT * FROM gender
	WHERE gender_id = p_gender_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteGender//

CREATE PROCEDURE deleteGender(
    IN p_gender_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM gender WHERE gender_id = p_gender_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkGenderExist//

CREATE PROCEDURE checkGenderExist(
    IN p_gender_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM gender
    WHERE gender_id = p_gender_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateGenderTable//

CREATE PROCEDURE generateGenderTable()
BEGIN
	SELECT gender_id, gender_name
    FROM gender 
    ORDER BY gender_id;
END //

DROP PROCEDURE IF EXISTS generateGenderOptions//

CREATE PROCEDURE generateGenderOptions()
BEGIN
	SELECT gender_id, gender_name 
    FROM gender 
    ORDER BY gender_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: RELATIONSHIP
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveRelationship//

CREATE PROCEDURE saveRelationship(
    IN p_relationship_id INT, 
    IN p_relationship_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_relationship_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_relationship_id IS NULL OR NOT EXISTS (SELECT 1 FROM relationship WHERE relationship_id = p_relationship_id) THEN
        INSERT INTO relationship (
            relationship_name,
            last_log_by
        ) 
        VALUES(
            p_relationship_name,
            p_last_log_by
        );
        
        SET v_new_relationship_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee_emergency_contact
        SET relationship_name   = p_relationship_name,
            last_log_by         = p_last_log_by
        WHERE relationship_id   = p_relationship_id;

        UPDATE relationship
        SET relationship_name   = p_relationship_name,
            last_log_by         = p_last_log_by
        WHERE relationship_id   = p_relationship_id;

        SET v_new_relationship_id = p_relationship_id;
    END IF;

    COMMIT;

    SELECT v_new_relationship_id AS new_relationship_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchRelationship//

CREATE PROCEDURE fetchRelationship(
    IN p_relationship_id INT
)
BEGIN
	SELECT * FROM relationship
	WHERE relationship_id = p_relationship_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteRelationship//

CREATE PROCEDURE deleteRelationship(
    IN p_relationship_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM relationship WHERE relationship_id = p_relationship_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkRelationshipExist//

CREATE PROCEDURE checkRelationshipExist(
    IN p_relationship_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM relationship
    WHERE relationship_id = p_relationship_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateRelationshipTable//

CREATE PROCEDURE generateRelationshipTable()
BEGIN
	SELECT relationship_id, relationship_name
    FROM relationship 
    ORDER BY relationship_id;
END //

DROP PROCEDURE IF EXISTS generateRelationshipOptions//

CREATE PROCEDURE generateRelationshipOptions()
BEGIN
	SELECT relationship_id, relationship_name 
    FROM relationship 
    ORDER BY relationship_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: RELIGION
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveReligion//

CREATE PROCEDURE saveReligion(
    IN p_religion_id INT, 
    IN p_religion_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_religion_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_religion_id IS NULL OR NOT EXISTS (SELECT 1 FROM religion WHERE religion_id = p_religion_id) THEN
        INSERT INTO religion (
            religion_name,
            last_log_by
        ) 
        VALUES(
            p_religion_name,
            p_last_log_by
        );
        
        SET v_new_religion_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET religion_name   = p_religion_name,
            last_log_by     = p_last_log_by
        WHERE religion_id   = p_religion_id;

        UPDATE religion
        SET religion_name   = p_religion_name,
            last_log_by     = p_last_log_by
        WHERE religion_id   = p_religion_id;

        SET v_new_religion_id = p_religion_id;
    END IF;

    COMMIT;

    SELECT v_new_religion_id AS new_religion_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchReligion//

CREATE PROCEDURE fetchReligion(
    IN p_religion_id INT
)
BEGIN
	SELECT * FROM religion
	WHERE religion_id = p_religion_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteReligion//

CREATE PROCEDURE deleteReligion(
    IN p_religion_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM religion WHERE religion_id = p_religion_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkReligionExist//

CREATE PROCEDURE checkReligionExist(
    IN p_religion_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM religion
    WHERE religion_id = p_religion_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateReligionTable//

CREATE PROCEDURE generateReligionTable()
BEGIN
	SELECT religion_id, religion_name
    FROM religion 
    ORDER BY religion_id;
END //

DROP PROCEDURE IF EXISTS generateReligionOptions//

CREATE PROCEDURE generateReligionOptions()
BEGIN
	SELECT religion_id, religion_name 
    FROM religion 
    ORDER BY religion_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: LANGUAGE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveLanguage//

CREATE PROCEDURE saveLanguage(
    IN p_language_id INT, 
    IN p_language_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_language_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_language_id IS NULL OR NOT EXISTS (SELECT 1 FROM language WHERE language_id = p_language_id) THEN
        INSERT INTO language (
            language_name,
            last_log_by
        ) 
        VALUES(
            p_language_name,
            p_last_log_by
        );
        
        SET v_new_language_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee_language
        SET language_name   = p_language_name,
            last_log_by     = p_last_log_by
        WHERE language_id   = p_language_id;

        UPDATE language
        SET language_name   = p_language_name,
            last_log_by     = p_last_log_by
        WHERE language_id   = p_language_id;

        SET v_new_language_id = p_language_id;
    END IF;

    COMMIT;

    SELECT v_new_language_id AS new_language_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchLanguage//

CREATE PROCEDURE fetchLanguage(
    IN p_language_id INT
)
BEGIN
	SELECT * FROM language
	WHERE language_id = p_language_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteLanguage//

CREATE PROCEDURE deleteLanguage(
    IN p_language_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM language WHERE language_id = p_language_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkLanguageExist//

CREATE PROCEDURE checkLanguageExist(
    IN p_language_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM language
    WHERE language_id = p_language_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateLanguageTable//

CREATE PROCEDURE generateLanguageTable()
BEGIN
	SELECT language_id, language_name
    FROM language 
    ORDER BY language_id;
END //

DROP PROCEDURE IF EXISTS generateLanguageOptions//

CREATE PROCEDURE generateLanguageOptions()
BEGIN
	SELECT language_id, language_name 
    FROM language 
    ORDER BY language_name;
END //

DROP PROCEDURE IF EXISTS generateEmployeeLanguageOptions//

CREATE PROCEDURE generateEmployeeLanguageOptions(
    IN p_employee_id INT
)
BEGIN
	SELECT language_id, language_name 
    FROM language
    WHERE language_id NOT IN (SELECT language_id FROM employee_language WHERE employee_id = p_employee_id)
    ORDER BY language_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: LANGUAGE PROFICIENCY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveLanguageProficiency//

CREATE PROCEDURE saveLanguageProficiency(
    IN p_language_proficiency_id INT, 
    IN p_language_proficiency_name VARCHAR(100), 
    IN p_language_proficiency_description VARCHAR(200),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_language_proficiency_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_language_proficiency_id IS NULL OR NOT EXISTS (SELECT 1 FROM language_proficiency WHERE language_proficiency_id = p_language_proficiency_id) THEN
        INSERT INTO language_proficiency (
            language_proficiency_name,
            language_proficiency_description,
            last_log_by
        ) 
        VALUES(
            p_language_proficiency_name,
            p_language_proficiency_description,
            p_last_log_by
        );
        
        SET v_new_language_proficiency_id = LAST_INSERT_ID();
    ELSE        
        UPDATE employee_language
        SET language_proficiency_name           = p_language_proficiency_name,
            last_log_by                         = p_last_log_by
        WHERE language_proficiency_id           = p_language_proficiency_id;

        UPDATE language_proficiency
        SET language_proficiency_name           = p_language_proficiency_name,
            language_proficiency_description    = p_language_proficiency_description,
            last_log_by                         = p_last_log_by
        WHERE language_proficiency_id           = p_language_proficiency_id;

        SET v_new_language_proficiency_id = p_language_proficiency_id;
    END IF;

    COMMIT;

    SELECT v_new_language_proficiency_id AS new_language_proficiency_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchLanguageProficiency//

CREATE PROCEDURE fetchLanguageProficiency(
    IN p_language_proficiency_id INT
)
BEGIN
	SELECT * FROM language_proficiency
	WHERE language_proficiency_id = p_language_proficiency_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteLanguageProficiency//

CREATE PROCEDURE deleteLanguageProficiency(
    IN p_language_proficiency_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM language_proficiency WHERE language_proficiency_id = p_language_proficiency_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkLanguageProficiencyExist//

CREATE PROCEDURE checkLanguageProficiencyExist(
    IN p_language_proficiency_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM language_proficiency
    WHERE language_proficiency_id = p_language_proficiency_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateLanguageProficiencyTable//

CREATE PROCEDURE generateLanguageProficiencyTable()
BEGIN
    SELECT language_proficiency_id, language_proficiency_name, language_proficiency_description 
    FROM language_proficiency
    ORDER BY language_proficiency_id;
END //

DROP PROCEDURE IF EXISTS generateLanguageProficiencyOptions//

CREATE PROCEDURE generateLanguageProficiencyOptions()
BEGIN
    SELECT language_proficiency_id, language_proficiency_name, language_proficiency_description
    FROM language_proficiency 
    ORDER BY language_proficiency_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: ADDRESS TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveAddressType//

CREATE PROCEDURE saveAddressType(
    IN p_address_type_id INT, 
    IN p_address_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_address_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_address_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM address_type WHERE address_type_id = p_address_type_id) THEN
        INSERT INTO address_type (
            address_type_name,
            last_log_by
        ) 
        VALUES(
            p_address_type_name,
            p_last_log_by
        );
        
        SET v_new_address_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE address_type
        SET address_type_name   = p_address_type_name,
            last_log_by         = p_last_log_by
        WHERE address_type_id   = p_address_type_id;

        SET v_new_address_type_id = p_address_type_id;
    END IF;

    COMMIT;

    SELECT v_new_address_type_id AS new_address_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchAddressType//

CREATE PROCEDURE fetchAddressType(
    IN p_address_type_id INT
)
BEGIN
	SELECT * FROM address_type
	WHERE address_type_id = p_address_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteAddressType//

CREATE PROCEDURE deleteAddressType(
    IN p_address_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM address_type WHERE address_type_id = p_address_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkAddressTypeExist//

CREATE PROCEDURE checkAddressTypeExist(
    IN p_address_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM address_type
    WHERE address_type_id = p_address_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateAddressTypeTable//

CREATE PROCEDURE generateAddressTypeTable()
BEGIN
	SELECT address_type_id, address_type_name
    FROM address_type 
    ORDER BY address_type_id;
END //

DROP PROCEDURE IF EXISTS generateAddressTypeOptions//

CREATE PROCEDURE generateAddressTypeOptions()
BEGIN
	SELECT address_type_id, address_type_name 
    FROM address_type 
    ORDER BY address_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: CONTACT INFORMATION TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveContactInformationType//

CREATE PROCEDURE saveContactInformationType(
    IN p_contact_information_type_id INT, 
    IN p_contact_information_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_contact_information_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_contact_information_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM contact_information_type WHERE contact_information_type_id = p_contact_information_type_id) THEN
        INSERT INTO contact_information_type (
            contact_information_type_name,
            last_log_by
        ) 
        VALUES(
            p_contact_information_type_name,
            p_last_log_by
        );
        
        SET v_new_contact_information_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE contact_information_type
        SET contact_information_type_name   = p_contact_information_type_name,
            last_log_by                     = p_last_log_by
        WHERE contact_information_type_id   = p_contact_information_type_id;

        SET v_new_contact_information_type_id = p_contact_information_type_id;
    END IF;

    COMMIT;

    SELECT v_new_contact_information_type_id AS new_contact_information_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchContactInformationType//

CREATE PROCEDURE fetchContactInformationType(
    IN p_contact_information_type_id INT
)
BEGIN
	SELECT * FROM contact_information_type
	WHERE contact_information_type_id = p_contact_information_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteContactInformationType//

CREATE PROCEDURE deleteContactInformationType(
    IN p_contact_information_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM contact_information_type WHERE contact_information_type_id = p_contact_information_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkContactInformationTypeExist//

CREATE PROCEDURE checkContactInformationTypeExist(
    IN p_contact_information_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM contact_information_type
    WHERE contact_information_type_id = p_contact_information_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateContactInformationTypeTable//

CREATE PROCEDURE generateContactInformationTypeTable()
BEGIN
	SELECT contact_information_type_id, contact_information_type_name
    FROM contact_information_type 
    ORDER BY contact_information_type_id;
END //

DROP PROCEDURE IF EXISTS generateContactInformationTypeOptions//

CREATE PROCEDURE generateContactInformationTypeOptions()
BEGIN
	SELECT contact_information_type_id, contact_information_type_name 
    FROM contact_information_type 
    ORDER BY contact_information_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: BANK
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveBank//

CREATE PROCEDURE saveBank(
    IN p_bank_id INT, 
    IN p_bank_name VARCHAR(100), 
    IN p_bank_identifier_code VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_bank_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_bank_id IS NULL OR NOT EXISTS (SELECT 1 FROM bank WHERE bank_id = p_bank_id) THEN
        INSERT INTO bank (
            bank_name,
            bank_identifier_code,
            last_log_by
        ) 
        VALUES(
            p_bank_name,
            p_bank_identifier_code,
            p_last_log_by
        );
        
        SET v_new_bank_id = LAST_INSERT_ID();
    ELSE        
        UPDATE bank
        SET bank_name               = p_bank_name,
            bank_identifier_code    = p_bank_identifier_code,
            last_log_by             = p_last_log_by
        WHERE bank_id               = p_bank_id;

        SET v_new_bank_id = p_bank_id;
    END IF;

    COMMIT;

    SELECT v_new_bank_id AS new_bank_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchBank//

CREATE PROCEDURE fetchBank(
    IN p_bank_id INT
)
BEGIN
	SELECT * FROM bank
	WHERE bank_id = p_bank_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteBank//

CREATE PROCEDURE deleteBank(
    IN p_bank_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM bank WHERE bank_id = p_bank_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkBankExist//

CREATE PROCEDURE checkBankExist(
    IN p_bank_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM bank
    WHERE bank_id = p_bank_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateBankTable//

CREATE PROCEDURE generateBankTable()
BEGIN
    SELECT bank_id, bank_name, bank_identifier_code FROM bank;
END //

DROP PROCEDURE IF EXISTS generateBankOptions//

CREATE PROCEDURE generateBankOptions()
BEGIN
    SELECT bank_id, bank_name
    FROM bank 
    ORDER BY bank_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: BANK ACCOUNT TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveBankAccountType//

CREATE PROCEDURE saveBankAccountType(
    IN p_bank_account_type_id INT, 
    IN p_bank_account_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_bank_account_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_bank_account_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM bank_account_type WHERE bank_account_type_id = p_bank_account_type_id) THEN
        INSERT INTO bank_account_type (
            bank_account_type_name,
            last_log_by
        ) 
        VALUES(
            p_bank_account_type_name,
            p_last_log_by
        );
        
        SET v_new_bank_account_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE bank_account_type
        SET bank_account_type_name  = p_bank_account_type_name,
            last_log_by             = p_last_log_by
        WHERE bank_account_type_id  = p_bank_account_type_id;

        SET v_new_bank_account_type_id = p_bank_account_type_id;
    END IF;

    COMMIT;

    SELECT v_new_bank_account_type_id AS new_bank_account_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchBankAccountType//

CREATE PROCEDURE fetchBankAccountType(
    IN p_bank_account_type_id INT
)
BEGIN
	SELECT * FROM bank_account_type
	WHERE bank_account_type_id = p_bank_account_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteBankAccountType//

CREATE PROCEDURE deleteBankAccountType(
    IN p_bank_account_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM bank_account_type
    WHERE bank_account_type_id = p_bank_account_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkBankAccountTypeExist//

CREATE PROCEDURE checkBankAccountTypeExist(
    IN p_bank_account_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM bank_account_type
    WHERE bank_account_type_id = p_bank_account_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateBankAccountTypeTable//

CREATE PROCEDURE generateBankAccountTypeTable()
BEGIN
	SELECT bank_account_type_id, bank_account_type_name
    FROM bank_account_type 
    ORDER BY bank_account_type_id;
END //

DROP PROCEDURE IF EXISTS generateBankAccountTypeOptions//

CREATE PROCEDURE generateBankAccountTypeOptions()
BEGIN
	SELECT bank_account_type_id, bank_account_type_name 
    FROM bank_account_type 
    ORDER BY bank_account_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: DEPARTMENT
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveDepartment//

CREATE PROCEDURE saveDepartment(
    IN p_department_id INT, 
    IN p_department_name VARCHAR(100), 
    IN p_parent_department_id INT, 
    IN p_parent_department_name VARCHAR(100), 
    IN p_manager_id INT, 
    IN p_manager_name VARCHAR(1000), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_department_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_department_id IS NULL OR NOT EXISTS (SELECT 1 FROM department WHERE department_id = p_department_id) THEN
        INSERT INTO department (
            department_name,
            parent_department_id,
            parent_department_name,
            manager_id,
            manager_name,
            last_log_by) 
        VALUES(
            p_department_name,
            p_parent_department_id,
            p_parent_department_name,
            p_manager_id,
            p_manager_name,
            p_last_log_by
        );
        
        SET v_new_department_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET department_name     = p_department_name,
            last_log_by         = p_last_log_by
        WHERE department_id     = p_department_id;

        UPDATE department
        SET parent_department_name  = p_department_name,
            last_log_by             = p_last_log_by
        WHERE parent_department_id  = p_department_id;

        UPDATE department
        SET department_name         = p_department_name,
            parent_department_id    = p_parent_department_id,
            parent_department_name  = p_parent_department_name,
            manager_id              = p_manager_id,
            manager_name            = p_manager_name,
            last_log_by             = p_last_log_by
        WHERE department_id         = p_department_id;

        SET v_new_department_id = p_department_id;
    END IF;

    COMMIT;

    SELECT v_new_department_id AS new_department_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchDepartment//

CREATE PROCEDURE fetchDepartment(
    IN p_department_id INT
)
BEGIN
	SELECT *
    FROM department
	WHERE department_id = p_department_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteDepartment//

CREATE PROCEDURE deleteDepartment(
    IN p_department_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM department
    WHERE department_id = p_department_id;

    COMMIT;
END //


/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkDepartmentExist//

CREATE PROCEDURE checkDepartmentExist(
    IN p_department_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM department
    WHERE department_id = p_department_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateDepartmentTable//

CREATE PROCEDURE generateDepartmentTable(
    IN p_filter_by_parent_department TEXT,
    IN p_filter_by_manager TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT department_id, department_name, parent_department_name, manager_name
                FROM department ';

    IF p_filter_by_parent_department IS NOT NULL AND p_filter_by_parent_department <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' parent_department_id IN (', p_filter_by_parent_department, ')');
    END IF;

    IF p_filter_by_manager IS NOT NULL AND p_filter_by_manager <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' manager_id IN (', p_filter_by_manager, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY department_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateDepartmentOptions//

CREATE PROCEDURE generateDepartmentOptions()
BEGIN
	SELECT department_id, department_name
    FROM department 
    ORDER BY department_name;
END //

DROP PROCEDURE IF EXISTS generateParentDepartmentOptions//

CREATE PROCEDURE generateParentDepartmentOptions(
    IN p_department_id INT
)
BEGIN
	SELECT department_id, department_name
    FROM department 
    WHERE department_id != p_department_id
    ORDER BY department_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: DEPARTURE REASON
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveDepartureReason//

CREATE PROCEDURE saveDepartureReason(
    IN p_departure_reason_id INT, 
    IN p_departure_reason_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_departure_reason_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_departure_reason_id IS NULL OR NOT EXISTS (SELECT 1 FROM departure_reason WHERE departure_reason_id = p_departure_reason_id) THEN
        INSERT INTO departure_reason (
            departure_reason_name,
            last_log_by
        ) 
        VALUES(
            p_departure_reason_name,
            p_last_log_by
        );
        
        SET v_new_departure_reason_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET departure_reason_name   = p_departure_reason_name,
            last_log_by             = p_last_log_by
        WHERE departure_reason_id   = p_departure_reason_id;
        
        UPDATE departure_reason
        SET departure_reason_name   = p_departure_reason_name,
            last_log_by             = p_last_log_by
        WHERE departure_reason_id   = p_departure_reason_id;

        SET v_new_departure_reason_id = p_departure_reason_id;
    END IF;

    COMMIT;

    SELECT v_new_departure_reason_id AS new_departure_reason_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchDepartureReason//

CREATE PROCEDURE fetchDepartureReason(
    IN p_departure_reason_id INT
)
BEGIN
	SELECT * FROM departure_reason
	WHERE departure_reason_id = p_departure_reason_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteDepartureReason//

CREATE PROCEDURE deleteDepartureReason(
    IN p_departure_reason_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM departure_reason
    WHERE departure_reason_id = p_departure_reason_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkDepartureReasonExist//

CREATE PROCEDURE checkDepartureReasonExist(
    IN p_departure_reason_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM departure_reason
    WHERE departure_reason_id = p_departure_reason_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateDepartureReasonTable//

CREATE PROCEDURE generateDepartureReasonTable()
BEGIN
	SELECT departure_reason_id, departure_reason_name
    FROM departure_reason 
    ORDER BY departure_reason_id;
END //

DROP PROCEDURE IF EXISTS generateDepartureReasonOptions//

CREATE PROCEDURE generateDepartureReasonOptions()
BEGIN
	SELECT departure_reason_id, departure_reason_name 
    FROM departure_reason 
    ORDER BY departure_reason_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: EMPLOYMENT LOCATION TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveEmploymentLocationType//

CREATE PROCEDURE saveEmploymentLocationType(
    IN p_employment_location_type_id INT, 
    IN p_employment_location_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_employment_location_type_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_employment_location_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM employment_location_type WHERE employment_location_type_id = p_employment_location_type_id) THEN
        INSERT INTO employment_location_type (
            employment_location_type_name,
            last_log_by
        ) 
        VALUES(
            p_employment_location_type_name,
            p_last_log_by
        );
        
        SET v_new_employment_location_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET employment_location_type_name   = p_employment_location_type_name,
            last_log_by                     = p_last_log_by
        WHERE employment_location_type_id   = p_employment_location_type_id;

        UPDATE employment_location_type
        SET employment_location_type_name   = p_employment_location_type_name,
            last_log_by                     = p_last_log_by
        WHERE employment_location_type_id   = p_employment_location_type_id;

        SET v_new_employment_location_type_id = p_employment_location_type_id;
    END IF;

    COMMIT;

    SELECT v_new_employment_location_type_id AS new_employment_location_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchEmploymentLocationType//

CREATE PROCEDURE fetchEmploymentLocationType(
    IN p_employment_location_type_id INT
)
BEGIN
	SELECT * FROM employment_location_type
	WHERE employment_location_type_id = p_employment_location_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteEmploymentLocationType//

CREATE PROCEDURE deleteEmploymentLocationType(
    IN p_employment_location_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employment_location_type
    WHERE employment_location_type_id = p_employment_location_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkEmploymentLocationTypeExist//

CREATE PROCEDURE checkEmploymentLocationTypeExist(
    IN p_employment_location_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM employment_location_type
    WHERE employment_location_type_id = p_employment_location_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateEmploymentLocationTypeTable//

CREATE PROCEDURE generateEmploymentLocationTypeTable()
BEGIN
	SELECT employment_location_type_id, employment_location_type_name
    FROM employment_location_type 
    ORDER BY employment_location_type_id;
END //

DROP PROCEDURE IF EXISTS generateEmploymentLocationTypeOptions//

CREATE PROCEDURE generateEmploymentLocationTypeOptions()
BEGIN
	SELECT employment_location_type_id, employment_location_type_name 
    FROM employment_location_type 
    ORDER BY employment_location_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: EMPLOYMENT TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveEmploymentType//

CREATE PROCEDURE saveEmploymentType(
    IN p_employment_type_id INT, 
    IN p_employment_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_employment_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_employment_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM employment_type WHERE employment_type_id = p_employment_type_id) THEN
        INSERT INTO employment_type (
            employment_type_name,
            last_log_by
        ) 
        VALUES(
            p_employment_type_name,
            p_last_log_by
        );
        
        SET v_new_employment_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET employment_type_name    = p_employment_type_name,
            last_log_by             = p_last_log_by
        WHERE employment_type_id    = p_employment_type_id;

        UPDATE employee_experience
        SET employment_type_name    = p_employment_type_name,
            last_log_by             = p_last_log_by
        WHERE employment_type_id    = p_employment_type_id;

        UPDATE employment_type
        SET employment_type_name    = p_employment_type_name,
            last_log_by             = p_last_log_by
        WHERE employment_type_id    = p_employment_type_id;

        SET v_new_employment_type_id = p_employment_type_id;
    END IF;

    COMMIT;

    SELECT v_new_employment_type_id AS new_employment_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchEmploymentType//

CREATE PROCEDURE fetchEmploymentType(
    IN p_employment_type_id INT
)
BEGIN
	SELECT * FROM employment_type
	WHERE employment_type_id = p_employment_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteEmploymentType//

CREATE PROCEDURE deleteEmploymentType(
    IN p_employment_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employment_type
    WHERE employment_type_id = p_employment_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkEmploymentTypeExist//

CREATE PROCEDURE checkEmploymentTypeExist(
    IN p_employment_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM employment_type
    WHERE employment_type_id = p_employment_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateEmploymentTypeTable//

CREATE PROCEDURE generateEmploymentTypeTable()
BEGIN
	SELECT employment_type_id, employment_type_name
    FROM employment_type 
    ORDER BY employment_type_id;
END //

DROP PROCEDURE IF EXISTS generateEmploymentTypeOptions//

CREATE PROCEDURE generateEmploymentTypeOptions()
BEGIN
	SELECT employment_type_id, employment_type_name 
    FROM employment_type 
    ORDER BY employment_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: JOB POSITION
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveJobPosition//
CREATE PROCEDURE saveJobPosition(
    IN p_job_position_id INT, 
    IN p_job_position_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_job_position_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_job_position_id IS NULL OR NOT EXISTS (SELECT 1 FROM job_position WHERE job_position_id = p_job_position_id) THEN
        INSERT INTO job_position (
            job_position_name,
            last_log_by
        ) 
        VALUES(
            p_job_position_name,
            p_last_log_by
        );
        
        SET v_new_job_position_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET job_position_name   = p_job_position_name,
            last_log_by         = p_last_log_by
        WHERE job_position_id   = p_job_position_id;

        UPDATE job_position
        SET job_position_name   = p_job_position_name,
            last_log_by         = p_last_log_by
        WHERE job_position_id   = p_job_position_id;

        SET v_new_job_position_id = p_job_position_id;
    END IF;

    COMMIT;

    SELECT v_new_job_position_id AS new_job_position_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchJobPosition//

CREATE PROCEDURE fetchJobPosition(
    IN p_job_position_id INT
)
BEGIN
	SELECT * FROM job_position
	WHERE job_position_id = p_job_position_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteJobPosition//

CREATE PROCEDURE deleteJobPosition(
    IN p_job_position_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM job_position
    WHERE job_position_id = p_job_position_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkJobPositionExist//

CREATE PROCEDURE checkJobPositionExist(
    IN p_job_position_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM job_position
    WHERE job_position_id = p_job_position_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateJobPositionTable//

CREATE PROCEDURE generateJobPositionTable()
BEGIN
	SELECT job_position_id, job_position_name
    FROM job_position 
    ORDER BY job_position_id;
END //

DROP PROCEDURE IF EXISTS generateJobPositionOptions//

CREATE PROCEDURE generateJobPositionOptions()
BEGIN
	SELECT job_position_id, job_position_name 
    FROM job_position 
    ORDER BY job_position_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: WORK LOCATION
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveWorkLocation//
CREATE PROCEDURE saveWorkLocation(
    IN p_work_location_id INT, 
    IN p_work_location_name VARCHAR(100), 
    IN p_address VARCHAR(1000), 
    IN p_city_id INT, 
    IN p_city_name VARCHAR(100), 
    IN p_state_id INT, 
    IN p_state_name VARCHAR(100), 
    IN p_country_id INT, 
    IN p_country_name VARCHAR(100), 
    IN p_phone VARCHAR(20), 
    IN p_telephone VARCHAR(20), 
    IN p_email VARCHAR(255), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_work_location_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_work_location_id IS NULL OR NOT EXISTS (SELECT 1 FROM work_location WHERE work_location_id = p_work_location_id) THEN
        INSERT INTO work_location (
            work_location_name,
            address,
            city_id,
            city_name,
            state_id,
            state_name,
            country_id,
            country_name,
            phone,
            telephone,
            email,
            last_log_by
        ) 
        VALUES(
            p_work_location_name,
            p_address,
            p_city_id,
            p_city_name,
            p_state_id,
            p_state_name,
            p_country_id,
            p_country_name,
            p_phone,
            p_telephone,
            p_email,
            p_last_log_by
        );
        
        SET v_new_work_location_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee
        SET work_location_name  = p_work_location_name,
            last_log_by         = p_last_log_by
        WHERE work_location_id  = p_work_location_id;

        UPDATE work_location
        SET work_location_name  = p_work_location_name,
            address             = p_address,
            city_id             = p_city_id,
            city_name           = p_city_name,
            state_id            = p_state_id,
            state_name          = p_state_name,
            country_id          = p_country_id,
            country_name        = p_country_name,
            phone               = p_phone,
            telephone           = p_telephone,
            email               = p_email,
            last_log_by         = p_last_log_by
        WHERE work_location_id  = p_work_location_id;

        SET v_new_work_location_id = p_work_location_id;
    END IF;

    COMMIT;

    SELECT v_new_work_location_id AS new_work_location_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchWorkLocation//

CREATE PROCEDURE fetchWorkLocation(
    IN p_work_location_id INT
)
BEGIN
	SELECT * FROM work_location
	WHERE work_location_id = p_work_location_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteWorkLocation//

CREATE PROCEDURE deleteWorkLocation(
    IN p_work_location_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM work_location
    WHERE work_location_id = p_work_location_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkWorkLocationExist//

CREATE PROCEDURE checkWorkLocationExist(
    IN p_work_location_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM work_location
    WHERE work_location_id = p_work_location_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateWorkLocationTable//

CREATE PROCEDURE generateWorkLocationTable(
    IN p_filter_by_city TEXT,
    IN p_filter_by_state TEXT,
    IN p_filter_by_country TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT work_location_id, work_location_name, address, city_name, state_name, country_name 
                FROM work_location ';

    IF p_filter_by_city IS NOT NULL AND p_filter_by_city <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' city_id IN (', p_filter_by_city, ')');
    END IF;

    IF p_filter_by_state IS NOT NULL AND p_filter_by_state <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' state_id IN (', p_filter_by_state, ')');
    END IF;

    IF p_filter_by_country IS NOT NULL AND p_filter_by_country <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;
        
        SET filter_conditions = CONCAT(filter_conditions, ' country_id IN (', p_filter_by_country, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY work_location_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateWorkLocationOptions//

CREATE PROCEDURE generateWorkLocationOptions()
BEGIN
	SELECT work_location_id, work_location_name 
    FROM work_location 
    ORDER BY work_location_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: EMPLOYEE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveEmployeeLanguage//

CREATE PROCEDURE saveEmployeeLanguage(
    IN p_employee_id INT, 
    IN p_language_id INT, 
    IN p_language_name VARCHAR(100), 
    IN p_language_proficiency_id INT, 
    IN p_language_proficiency_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM employee_language WHERE employee_id = p_employee_id AND language_id = p_language_id) THEN
       INSERT INTO employee_language (
            employee_id,
            language_id,
            language_name,
            language_proficiency_id,
            language_proficiency_name,
            last_log_by
        ) 
        VALUES(
            p_employee_id,
            p_language_id,
            p_language_name,
            p_language_proficiency_id,
            p_language_proficiency_name,
            p_last_log_by
        );
    ELSE
        UPDATE employee_language
        SET language_proficiency_id     = p_language_proficiency_id,
            language_proficiency_name   = p_language_proficiency_name,
            last_log_by                 = p_last_log_by
        WHERE employee_id               = p_employee_id AND language_id = p_language_id;
    END IF;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS saveEmployeeEducation//

CREATE PROCEDURE saveEmployeeEducation(
    IN p_employee_education_id INT, 
    IN p_employee_id INT, 
    IN p_school VARCHAR(100), 
    IN p_degree VARCHAR(100), 
    IN p_field_of_study VARCHAR(100), 
    IN p_start_month VARCHAR(20), 
    IN p_start_year VARCHAR(20), 
    IN p_end_month VARCHAR(20), 
    IN p_end_year VARCHAR(20), 
    IN p_activities_societies VARCHAR(5000), 
    IN p_education_description VARCHAR(5000), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM employee_education WHERE employee_education_id = p_employee_education_id) THEN
       INSERT INTO employee_education (
            employee_id,
            school,
            degree,
            field_of_study,
            start_month,
            start_year,
            end_month,
            end_year,
            activities_societies,
            education_description,
            last_log_by
        ) 
        VALUES(
            p_employee_id,
            p_school,
            p_degree,
            p_field_of_study,
            p_start_month,
            p_start_year,
            p_end_month,
            p_end_year,
            p_activities_societies,
            p_education_description,
            p_last_log_by
        );
    ELSE
        UPDATE employee_education
        SET school                      = p_school,
            degree                      = p_degree,
            field_of_study              = p_field_of_study,
            start_month                 = p_start_month,
            start_year                  = p_start_year,
            end_month                   = p_end_month,
            end_year                    = p_end_year,
            activities_societies        = p_activities_societies,
            education_description       = p_education_description,
            last_log_by                 = p_last_log_by
        WHERE employee_education_id     = p_employee_education_id;
    END IF;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS saveEmployeeEmergencyContact//

CREATE PROCEDURE saveEmployeeEmergencyContact(
    IN p_employee_emergency_contact_id INT, 
    IN p_employee_id INT, 
    IN p_emergency_contact_name VARCHAR(500),
    IN p_relationship_id INT,
    IN p_relationship_name VARCHAR(100),
    IN p_telephone VARCHAR(50),
    IN p_mobile VARCHAR(50),
    IN p_email VARCHAR(200),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM employee_emergency_contact WHERE employee_emergency_contact_id = p_employee_emergency_contact_id) THEN
       INSERT INTO employee_emergency_contact (
            employee_id,
            emergency_contact_name,
            relationship_id,
            relationship_name,
            telephone,
            mobile,
            email,
            last_log_by
        ) 
        VALUES(
            p_employee_id,
            p_emergency_contact_name,
            p_relationship_id,
            p_relationship_name,
            p_telephone,
            p_mobile,
            p_email,
            p_last_log_by
        );
    ELSE
        UPDATE employee_emergency_contact
        SET emergency_contact_name              = p_emergency_contact_name,
            relationship_id                     = p_relationship_id,
            relationship_name                   = p_relationship_name,
            telephone                           = p_telephone,
            mobile                              = p_mobile,
            email                               = p_email,
            last_log_by                         = p_last_log_by
        WHERE employee_emergency_contact_id     = p_employee_emergency_contact_id;
    END IF;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS saveEmployeeLicense//

CREATE PROCEDURE saveEmployeeLicense(
    IN p_employee_license_id INT, 
    IN p_employee_id INT, 
    IN p_licensed_profession VARCHAR(200), 
    IN p_licensing_body VARCHAR(200), 
    IN p_license_number VARCHAR(200), 
    IN p_issue_date DATE, 
    IN p_expiration_date DATE, 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM employee_license WHERE employee_license_id = p_employee_license_id) THEN
       INSERT INTO employee_license (
            employee_id,
            licensed_profession,
            licensing_body,
            license_number,
            issue_date,
            expiration_date,
            last_log_by
        ) 
        VALUES(
            p_employee_id,
            p_licensed_profession,
            p_licensing_body,
            p_license_number,
            p_issue_date,
            p_expiration_date,
            p_last_log_by
        );
    ELSE
        UPDATE employee_license
        SET licensed_profession     = p_licensed_profession,
            licensing_body          = p_licensing_body,
            license_number          = p_license_number,
            issue_date              = p_issue_date,
            expiration_date         = p_expiration_date,
            last_log_by             = p_last_log_by
        WHERE employee_license_id   = p_employee_license_id;
    END IF;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS saveEmployeeExperience//

CREATE PROCEDURE saveEmployeeExperience(
    IN p_employee_experience_id INT, 
    IN p_employee_id INT, 
    IN p_job_title VARCHAR(100),
    IN p_employment_type_id INT,
    IN p_employment_type_name VARCHAR(100),
    IN p_company_name VARCHAR(200),
    IN p_location VARCHAR(200),
    IN p_start_month VARCHAR(20),
    IN p_start_year VARCHAR(20),
    IN p_end_month VARCHAR(20),
    IN p_end_year VARCHAR(20),
    IN p_job_description VARCHAR(5000),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM employee_experience WHERE employee_experience_id = p_employee_experience_id) THEN
       INSERT INTO employee_experience (
            employee_id,
            job_title,
            employment_type_id,
            employment_type_name,
            company_name,
            location,
            start_month,
            start_year,
            end_month,
            end_year,
            job_description,
            last_log_by
        ) 
        VALUES(
            p_employee_id,
            p_job_title,
            p_employment_type_id,
            p_employment_type_name,
            p_company_name,
            p_location,
            p_start_month,
            p_start_year,
            p_end_month,
            p_end_year,
            p_job_description,
            p_last_log_by
        );
    ELSE
        UPDATE employee_experience
        SET job_title                   = p_job_title,
            employment_type_id          = p_employment_type_id,
            employment_type_name        = p_employment_type_name,
            company_name                = p_company_name,
            location                    = p_location,
            start_month                 = p_start_month,
            start_year                  = p_start_year,
            end_month                   = p_end_month,
            end_year                    = p_end_year,
            job_description             = p_job_description,
            last_log_by                 = p_last_log_by
        WHERE employee_experience_id    = p_employee_experience_id;
    END IF;

    COMMIT;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS insertEmployee//

CREATE PROCEDURE insertEmployee(
    IN p_full_name VARCHAR(1000),
    IN p_first_name VARCHAR(300),
    IN p_middle_name VARCHAR(300),
    IN p_last_name VARCHAR(300),
    IN p_suffix VARCHAR(10),
    IN p_company_id INT,
    IN p_company_name VARCHAR(100),
    IN p_department_id INT,
    IN p_department_name VARCHAR(100),
    IN p_job_position_id INT,
    IN p_job_position_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_employee_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO employee (
        full_name,
        first_name,
        middle_name,
        last_name,
        suffix,
        company_id,
        company_name,
        department_id,
        department_name,
        job_position_id,
        job_position_name,
        last_log_by
    ) 
    VALUES(
        p_full_name,
        p_first_name,
        p_middle_name,
        p_last_name,
        p_suffix,
        p_company_id,
        p_company_name,
        p_department_id,
        p_department_name,
        p_job_position_id,
        p_job_position_name,
        p_last_log_by
    );

    SET v_new_employee_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_new_employee_id AS new_employee_id;
END //

DROP PROCEDURE IF EXISTS insertEmployeeDocument//

CREATE PROCEDURE insertEmployeeDocument(
    IN p_employee_id INT,
    IN p_document_name VARCHAR(200),
    IN p_document_file VARCHAR(500),
    IN p_employee_document_type_id INT,
    IN p_employee_document_type_name VARCHAR(500),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO employee_document (
        employee_id,
        document_name,
        document_file,
        employee_document_type_id,
        employee_document_type_name,
        last_log_by
    ) 
    VALUES(
        p_employee_id,
        p_document_name,
        p_document_file,
        p_employee_document_type_id,
        p_employee_document_type_name,
        p_last_log_by
    );

    COMMIT;
END //

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateEmployeePersonalDetails//

CREATE PROCEDURE updateEmployeePersonalDetails(
    IN p_employee_id INT,
    IN p_full_name VARCHAR(1000),
    IN p_first_name VARCHAR(300),
    IN p_middle_name VARCHAR(300),
    IN p_last_name VARCHAR(300),
    IN p_suffix VARCHAR(10),
    IN p_nickname VARCHAR(100),
    IN p_private_address VARCHAR(500),
    IN p_private_address_city_id INT,
    IN p_private_address_city_name VARCHAR(100),
    IN p_private_address_state_id INT,
    IN p_private_address_state_name VARCHAR(100),
    IN p_private_address_country_id INT,
    IN p_private_address_country_name VARCHAR(100),
    IN p_civil_status_id INT,
    IN p_civil_status_name VARCHAR(100),
    IN p_dependents INT,
    IN p_religion_id INT,
    IN p_religion_name VARCHAR(100),
    IN p_blood_type_id INT,
    IN p_blood_type_name VARCHAR(100),
    IN p_home_work_distance FLOAT,
    IN p_height FLOAT,
    IN p_weight FLOAT,
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE department
    SET manager_name    = p_full_name,
        last_log_by     = p_last_log_by
    WHERE manager_id    = p_employee_id;

    UPDATE employee
    SET manager_name    = p_full_name,
        last_log_by     = p_last_log_by
    WHERE manager_id    = p_employee_id;

    UPDATE employee
    SET time_off_approver_name  = p_full_name,
        last_log_by             = p_last_log_by
    WHERE time_off_approver_id  = p_employee_id;

    UPDATE employee
    SET full_name                       = p_full_name,
        first_name                      = p_first_name,
        middle_name                     = p_middle_name,
        last_name                       = p_last_name,
        suffix                          = p_suffix,
        nickname                        = p_nickname,
        private_address                 = p_private_address,
        private_address_city_id         = p_private_address_city_id,
        private_address_city_name       = p_private_address_city_name,
        private_address_state_id        = p_private_address_state_id,
        private_address_state_name      = p_private_address_state_name,
        private_address_country_id      = p_private_address_country_id,
        private_address_country_name    = p_private_address_country_name,
        civil_status_id                 = p_civil_status_id,
        civil_status_name               = p_civil_status_name,
        dependents                      = p_dependents,
        religion_id                     = p_religion_id,
        religion_name                   = p_religion_name,
        blood_type_id                   = p_blood_type_id,
        blood_type_name                 = p_blood_type_name,
        home_work_distance              = p_home_work_distance,
        height                          = p_height,
        weight                          = p_weight,
        last_log_by                     = p_last_log_by
    WHERE employee_id                   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeePINCode//

CREATE PROCEDURE updateEmployeePINCode(
    IN p_employee_id INT,
    IN p_pin_code VARCHAR(255),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET pin_code        = p_pin_code,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeBadgeId//

CREATE PROCEDURE updateEmployeeBadgeId(
    IN p_employee_id INT,
    IN p_badge_id VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET badge_id        = p_badge_id,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeePrivateEmail//

CREATE PROCEDURE updateEmployeePrivateEmail(
    IN p_employee_id INT,
    IN p_private_email VARCHAR(255),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET private_email   = p_private_email,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeePrivatePhone//

CREATE PROCEDURE updateEmployeePrivatePhone(
    IN p_employee_id INT,
    IN p_private_phone VARCHAR(20),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET private_phone   = p_private_phone,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeePrivateTelephone//

CREATE PROCEDURE updateEmployeePrivateTelephone(
    IN p_employee_id INT,
    IN p_private_telephone VARCHAR(20),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET private_telephone   = p_private_telephone,
        last_log_by         = p_last_log_by
    WHERE employee_id       = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeNationality//

CREATE PROCEDURE updateEmployeeNationality(
    IN p_employee_id INT,
    IN p_nationality_id INT,
    IN p_nationality_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET nationality_id      = p_nationality_id,
        nationality_name    = p_nationality_name,
        last_log_by         = p_last_log_by
    WHERE employee_id       = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeGender//

CREATE PROCEDURE updateEmployeeGender(
    IN p_employee_id INT,
    IN p_gender_id INT,
    IN p_gender_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET gender_id       = p_gender_id,
        gender_name     = p_gender_name,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeBirthday//

CREATE PROCEDURE updateEmployeeBirthday(
    IN p_employee_id INT,
    IN p_birthday DATE,
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET birthday        = p_birthday,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeePlaceOfBirth//

CREATE PROCEDURE updateEmployeePlaceOfBirth(
    IN p_employee_id INT,
    IN p_place_of_birth VARCHAR(1000),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET place_of_birth  = p_place_of_birth,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeCompany//

CREATE PROCEDURE updateEmployeeCompany(
    IN p_employee_id INT,
    IN p_company_id INT,
    IN p_company_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET company_id      = p_company_id,
        company_name    = p_company_name,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeDepartment//

CREATE PROCEDURE updateEmployeeDepartment(
    IN p_employee_id INT,
    IN p_department_id INT,
    IN p_department_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET department_id       = p_department_id,
        department_name     = p_department_name,
        last_log_by         = p_last_log_by
    WHERE employee_id       = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeJobPosition//

CREATE PROCEDURE updateEmployeeJobPosition(
    IN p_employee_id INT,
    IN p_job_position_id INT,
    IN p_job_position_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET job_position_id     = p_job_position_id,
        job_position_name   = p_job_position_name,
        last_log_by         = p_last_log_by
    WHERE employee_id       = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeManager//

CREATE PROCEDURE updateEmployeeManager(
    IN p_employee_id INT,
    IN p_manager_id INT,
    IN p_manager_name VARCHAR(1000),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET manager_id      = p_manager_id,
        manager_name    = p_manager_name,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeTimeOffApprover//

CREATE PROCEDURE updateEmployeeTimeOffApprover(
    IN p_employee_id INT,
    IN p_time_off_approver_id INT,
    IN p_time_off_approver_name VARCHAR(1000),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET time_off_approver_id    = p_time_off_approver_id,
        time_off_approver_name  = p_time_off_approver_name,
        last_log_by             = p_last_log_by
    WHERE employee_id           = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeEmploymentType//

CREATE PROCEDURE updateEmployeeEmploymentType(
    IN p_employee_id INT,
    IN p_employment_type_id INT,
    IN p_employment_type_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET employment_type_id      = p_employment_type_id,
        employment_type_name    = p_employment_type_name,
        last_log_by             = p_last_log_by
    WHERE employee_id           = p_employee_id;

     COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeEmploymentLocationType//

CREATE PROCEDURE updateEmployeeEmploymentLocationType(
    IN p_employee_id INT,
    IN p_employment_location_type_id INT,
    IN p_employment_location_type_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET employment_location_type_id     = p_employment_location_type_id,
        employment_location_type_name   = p_employment_location_type_name,
        last_log_by                     = p_last_log_by
    WHERE employee_id                   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeWorkLocation//

CREATE PROCEDURE updateEmployeeWorkLocation(
    IN p_employee_id INT,
    IN p_work_location_id INT,
    IN p_work_location_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET work_location_id    = p_work_location_id,
        work_location_name  = p_work_location_name,
        last_log_by         = p_last_log_by
    WHERE employee_id       = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeOnBoardDate//

CREATE PROCEDURE updateEmployeeOnBoardDate(
    IN p_employee_id INT,
    IN p_on_board_date DATE,
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET on_board_date   = p_on_board_date,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeWorkEmail//

CREATE PROCEDURE updateEmployeeWorkEmail(
    IN p_employee_id INT,
    IN p_work_email VARCHAR(255),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET work_email      = p_work_email,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeWorkPhone//

CREATE PROCEDURE updateEmployeeWorkPhone(
    IN p_employee_id INT,
    IN p_work_phone VARCHAR(20),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET work_phone      = p_work_phone,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeWorkTelephone//

CREATE PROCEDURE updateEmployeeWorkTelephone(
    IN p_employee_id INT,
    IN p_work_telephone VARCHAR(20),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET work_telephone  = p_work_telephone,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeImage//

CREATE PROCEDURE updateEmployeeImage(
	IN p_employee_id INT, 
	IN p_employee_image VARCHAR(500), 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET employee_image  = p_employee_image,
        last_log_by     = p_last_log_by
    WHERE employee_id   = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeArchive//

CREATE PROCEDURE updateEmployeeArchive(
	IN p_employee_id INT, 
	IN p_departure_reason_id INT, 
	IN p_departure_reason_name VARCHAR(500), 
	IN p_detailed_departure_reason VARCHAR(5000), 
	IN p_departure_date DATE, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET employment_status           = 'Archived',
        departure_reason_id         = p_departure_reason_id,
        departure_reason_name       = p_departure_reason_name,
        detailed_departure_reason   = p_detailed_departure_reason,
        departure_date              = p_departure_date,
        last_log_by                 = p_last_log_by
    WHERE employee_id               = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateEmployeeUnarchive//

CREATE PROCEDURE updateEmployeeUnarchive(
	IN p_employee_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE employee
    SET employment_status           = 'Active',
        last_log_by                 = p_last_log_by
    WHERE employee_id               = p_employee_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchEmployee//

CREATE PROCEDURE fetchEmployee(
    IN p_employee_id INT
)
BEGIN
	SELECT * FROM employee
	WHERE employee_id = p_employee_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchEmployeeEducation//

CREATE PROCEDURE fetchEmployeeEducation(
    IN p_employee_education_id INT
)
BEGIN
	SELECT * FROM employee_education
	WHERE employee_education_id = p_employee_education_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchEmployeeEmergencyContact//

CREATE PROCEDURE fetchEmployeeEmergencyContact(
    IN p_employee_emergency_contact_id INT
)
BEGIN
	SELECT * FROM employee_emergency_contact
	WHERE employee_emergency_contact_id = p_employee_emergency_contact_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchEmployeeLicense//

CREATE PROCEDURE fetchEmployeeLicense(
    IN p_employee_license_id INT
)
BEGIN
	SELECT * FROM employee_license
	WHERE employee_license_id = p_employee_license_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchEmployeeExperience//

CREATE PROCEDURE fetchEmployeeExperience(
    IN p_employee_experience_id INT
)
BEGIN
	SELECT * FROM employee_experience
	WHERE employee_experience_id = p_employee_experience_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchEmployeeDocument//

CREATE PROCEDURE fetchEmployeeDocument(
    IN p_employee_document_id INT
)
BEGIN
	SELECT * FROM employee_document
	WHERE employee_document_id = p_employee_document_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchAllEmployeeDocument//

CREATE PROCEDURE fetchAllEmployeeDocument(
    IN p_employee_id INT
)
BEGIN
	SELECT * FROM employee_document
	WHERE employee_id = p_employee_id;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteEmployee//

CREATE PROCEDURE deleteEmployee(
    IN p_employee_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_experience
    WHERE employee_id = p_employee_id;

    DELETE FROM employee_education
    WHERE employee_id = p_employee_id;

    DELETE FROM employee_license
    WHERE employee_id = p_employee_id;

    DELETE FROM employee_emergency_contact
    WHERE employee_id = p_employee_id;

    DELETE FROM employee_language
    WHERE employee_id = p_employee_id;

    DELETE FROM employee_document
    WHERE employee_id = p_employee_id;

    DELETE FROM employee
    WHERE employee_id = p_employee_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteEmployeeLanguage//

CREATE PROCEDURE deleteEmployeeLanguage(
    IN p_employee_language_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_language
    WHERE employee_language_id = p_employee_language_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteEmployeeEducation//

CREATE PROCEDURE deleteEmployeeEducation(
    IN p_employee_education_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_education
    WHERE employee_education_id = p_employee_education_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteEmployeeEmergencyContact//

CREATE PROCEDURE deleteEmployeeEmergencyContact(
    IN p_employee_emergency_contact_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_emergency_contact
    WHERE employee_emergency_contact_id = p_employee_emergency_contact_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteEmployeeLicense//

CREATE PROCEDURE deleteEmployeeLicense(
    IN p_employee_license_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_license
    WHERE employee_license_id = p_employee_license_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteEmployeeExperience//

CREATE PROCEDURE deleteEmployeeExperience(
    IN p_employee_experience_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_experience
    WHERE employee_experience_id = p_employee_experience_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteEmployeeDocument//

CREATE PROCEDURE deleteEmployeeDocument(
    IN p_employee_document_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_document
    WHERE employee_document_id = p_employee_document_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkEmployeeExist//

CREATE PROCEDURE checkEmployeeExist(
    IN p_employee_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM employee
    WHERE employee_id = p_employee_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateEmployeeCard//

CREATE PROCEDURE generateEmployeeCard(
    IN p_search_value TEXT,
    IN p_filter_by_company TEXT,
    IN p_filter_by_department TEXT,
    IN p_filter_by_job_position TEXT,
    IN p_filter_by_employee_status TEXT,
    IN p_filter_by_work_location TEXT,
    IN p_filter_by_employment_type TEXT,
    IN p_filter_by_gender TEXT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    DECLARE query TEXT;

    -- Base query
    SET query = 'SELECT employee_id, employee_image, full_name, department_name, job_position_name, employment_status
                 FROM employee
                 WHERE 1=1';

    -- Search filter
    IF p_search_value IS NOT NULL AND p_search_value <> '' THEN
        SET query = CONCAT(query, ' 
            AND (
                first_name LIKE ? OR
                middle_name LIKE ? OR
                last_name LIKE ? OR
                suffix LIKE ? OR
                department_name LIKE ? OR
                job_position_name LIKE ? OR
                employment_status LIKE ?
            )');
    END IF;

    -- Dynamic filters
    IF p_filter_by_company IS NOT NULL AND p_filter_by_company <> '' THEN
        SET query = CONCAT(query, ' AND company_id IN (', p_filter_by_company, ')');
    END IF;

    IF p_filter_by_department IS NOT NULL AND p_filter_by_department <> '' THEN
        SET query = CONCAT(query, ' AND department_id IN (', p_filter_by_department, ')');
    END IF;

    IF p_filter_by_job_position IS NOT NULL AND p_filter_by_job_position <> '' THEN
        SET query = CONCAT(query, ' AND job_position_id IN (', p_filter_by_job_position, ')');
    END IF;

    IF p_filter_by_employee_status IS NOT NULL AND p_filter_by_employee_status <> '' THEN
        SET query = CONCAT(query, ' AND employment_status IN (', p_filter_by_employee_status, ')');
    END IF;

    IF p_filter_by_work_location IS NOT NULL AND p_filter_by_work_location <> '' THEN
        SET query = CONCAT(query, ' AND work_location_id IN (', p_filter_by_work_location, ')');
    END IF;

    IF p_filter_by_employment_type IS NOT NULL AND p_filter_by_employment_type <> '' THEN
        SET query = CONCAT(query, ' AND employment_type_id IN (', p_filter_by_employment_type, ')');
    END IF;

    IF p_filter_by_gender IS NOT NULL AND p_filter_by_gender <> '' THEN
        SET query = CONCAT(query, ' AND gender_id IN (', p_filter_by_gender, ')');
    END IF;

    -- Final ordering + limit
    SET query = CONCAT(query, ' ORDER BY full_name LIMIT ?, ?');

    PREPARE stmt FROM query;

    -- Bind parameters for search + pagination
    IF p_search_value IS NOT NULL AND p_search_value <> '' THEN
        SET @s1 = CONCAT('%', p_search_value, '%');
        SET @s2 = @s1; SET @s3 = @s1; SET @s4 = @s1;
        SET @s5 = @s1; SET @s6 = @s1; SET @s7 = @s1;
        SET @offset = p_offset;
        SET @limit  = p_limit;

        EXECUTE stmt USING @s1, @s2, @s3, @s4, @s5, @s6, @s7, @offset, @limit;
    ELSE
        SET @offset = p_offset;
        SET @limit  = p_limit;

        EXECUTE stmt USING @offset, @limit;
    END IF;

    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateEmployeeTable//

CREATE PROCEDURE generateEmployeeTable(
    IN p_filter_by_company TEXT,
    IN p_filter_by_department TEXT,
    IN p_filter_by_job_position TEXT,
    IN p_filter_by_employee_status TEXT,
    IN p_filter_by_work_location TEXT,
    IN p_filter_by_employment_type TEXT,
    IN p_filter_by_gender TEXT
)
BEGIN
    DECLARE query TEXT DEFAULT 
        'SELECT employee_id, employee_image, full_name, department_name, job_position_name, employment_status
        FROM employee WHERE 1=1';

   IF p_filter_by_company IS NOT NULL AND p_filter_by_company <> '' THEN
        SET query = CONCAT(query, ' AND company_id IN (', p_filter_by_company, ')');
    END IF;

    IF p_filter_by_department IS NOT NULL AND p_filter_by_department <> '' THEN
        SET query = CONCAT(query, ' AND department_id IN (', p_filter_by_department, ')');
    END IF;

    IF p_filter_by_job_position IS NOT NULL AND p_filter_by_job_position <> '' THEN
        SET query = CONCAT(query, ' AND job_position_id IN (', p_filter_by_job_position, ')');
    END IF;

    IF p_filter_by_employee_status IS NOT NULL AND p_filter_by_employee_status <> '' THEN
        SET query = CONCAT(query, ' AND employment_status IN (', p_filter_by_employee_status, ')');
    END IF;

    IF p_filter_by_work_location IS NOT NULL AND p_filter_by_work_location <> '' THEN
        SET query = CONCAT(query, ' AND work_location_id IN (', p_filter_by_work_location, ')');
    END IF;

    IF p_filter_by_employment_type IS NOT NULL AND p_filter_by_employment_type <> '' THEN
        SET query = CONCAT(query, ' AND employment_type_id IN (', p_filter_by_employment_type, ')');
    END IF;

    IF p_filter_by_gender IS NOT NULL AND p_filter_by_gender <> '' THEN
        SET query = CONCAT(query, ' AND gender_id IN (', p_filter_by_gender, ')');
    END IF;

    SET query = CONCAT(query, ' ORDER BY full_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateEmployeeOptions//

CREATE PROCEDURE generateEmployeeOptions()
BEGIN
	SELECT employee_id, full_name
    FROM employee 
    ORDER BY full_name;
END //

DROP PROCEDURE IF EXISTS generateEmployeeLanguageList//

CREATE PROCEDURE generateEmployeeLanguageList(
    IN p_employee_id INT
)
BEGIN
	SELECT employee_language_id, language_name, language_proficiency_name
    FROM employee_language
    WHERE employee_id = p_employee_id
    ORDER BY language_name;
END //

DROP PROCEDURE IF EXISTS generateEmployeeEducationList//

CREATE PROCEDURE generateEmployeeEducationList(
    IN p_employee_id INT
)
BEGIN
    SELECT 
        employee_education_id, 
        school, 
        degree, 
        field_of_study, 
        start_month, 
        start_year, 
        end_month, 
        end_year, 
        activities_societies, 
        education_description
    FROM employee_education
    WHERE employee_id = p_employee_id
    ORDER BY
        CASE 
            WHEN (end_year IS NULL OR end_year = '' OR end_month IS NULL OR end_month = '') THEN 1
            ELSE 0
        END DESC,
        COALESCE(NULLIF(end_year, ''), start_year) DESC,
        COALESCE(NULLIF(end_month, ''), start_month) DESC;
END //

DROP PROCEDURE IF EXISTS generateEmployeeEmergencyContactList//

CREATE PROCEDURE generateEmployeeEmergencyContactList(
    IN p_employee_id INT
)
BEGIN
    SELECT 
        employee_emergency_contact_id, 
        emergency_contact_name, 
        relationship_name, 
        telephone, 
        mobile, 
        email
    FROM employee_emergency_contact
    WHERE employee_id = p_employee_id
    ORDER BY emergency_contact_name;
END //

DROP PROCEDURE IF EXISTS generateEmployeeLicenseList//

CREATE PROCEDURE generateEmployeeLicenseList(
    IN p_employee_id INT
)
BEGIN
    SELECT 
        employee_license_id, 
        licensed_profession, 
        licensing_body, 
        license_number, 
        issue_date, 
        expiration_date
    FROM employee_license
    WHERE employee_id = p_employee_id
    ORDER BY licensed_profession;
END //

DROP PROCEDURE IF EXISTS generateEmployeeExperienceList//

CREATE PROCEDURE generateEmployeeExperienceList(
    IN p_employee_id INT
)
BEGIN
    SELECT 
        employee_experience_id, 
        job_title, 
        employment_type_name, 
        company_name, 
        location, 
        start_month, 
        start_year, 
        end_month, 
        end_year, 
        job_description
    FROM employee_experience
    WHERE employee_id = p_employee_id
    ORDER BY
        CASE 
            WHEN (end_year IS NULL OR end_year = '' OR end_month IS NULL OR end_month = '') THEN 1
            ELSE 0
        END DESC,
        COALESCE(NULLIF(end_year, ''), start_year) DESC,
        COALESCE(NULLIF(end_month, ''), start_month) DESC;
END //

DROP PROCEDURE IF EXISTS generateEmployeeDocumentTable//

CREATE PROCEDURE generateEmployeeDocumentTable(
    IN p_employee_id INT
)
BEGIN
    SELECT 
        employee_document_id, 
        document_name, 
        document_file, 
        employee_document_type_name, 
        created_date, 
        last_updated
    FROM employee_document
    WHERE employee_id = p_employee_id
    ORDER BY created_date DESC;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: EMPLOYEE DOCUMENT TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveEmployeeDocumentType//

CREATE PROCEDURE saveEmployeeDocumentType(
    IN p_employee_document_type_id INT, 
    IN p_employee_document_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_employee_document_type_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_employee_document_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM employee_document_type WHERE employee_document_type_id = p_employee_document_type_id) THEN
        INSERT INTO employee_document_type (
            employee_document_type_name,
            last_log_by
        ) 
        VALUES(
            p_employee_document_type_name,
            p_last_log_by
        );
        
        SET v_new_employee_document_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE employee_document
        SET employee_document_type_name   = p_employee_document_type_name,
            last_log_by                     = p_last_log_by
        WHERE employee_document_type_id   = p_employee_document_type_id;

        UPDATE employee_document_type
        SET employee_document_type_name   = p_employee_document_type_name,
            last_log_by                     = p_last_log_by
        WHERE employee_document_type_id   = p_employee_document_type_id;

        SET v_new_employee_document_type_id = p_employee_document_type_id;
    END IF;

    COMMIT;

    SELECT v_new_employee_document_type_id AS new_employee_document_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchEmployeeDocumentType//

CREATE PROCEDURE fetchEmployeeDocumentType(
    IN p_employee_document_type_id INT
)
BEGIN
	SELECT * FROM employee_document_type
	WHERE employee_document_type_id = p_employee_document_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteEmployeeDocumentType//

CREATE PROCEDURE deleteEmployeeDocumentType(
    IN p_employee_document_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM employee_document_type
    WHERE employee_document_type_id = p_employee_document_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkEmployeeDocumentTypeExist//

CREATE PROCEDURE checkEmployeeDocumentTypeExist(
    IN p_employee_document_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM employee_document_type
    WHERE employee_document_type_id = p_employee_document_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateEmployeeDocumentTypeTable//

CREATE PROCEDURE generateEmployeeDocumentTypeTable()
BEGIN
	SELECT employee_document_type_id, employee_document_type_name
    FROM employee_document_type 
    ORDER BY employee_document_type_id;
END //

DROP PROCEDURE IF EXISTS generateEmployeeDocumentTypeOptions//

CREATE PROCEDURE generateEmployeeDocumentTypeOptions()
BEGIN
	SELECT employee_document_type_id, employee_document_type_name 
    FROM employee_document_type 
    ORDER BY employee_document_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: ATTRIBUTE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveAttribute//

CREATE PROCEDURE saveAttribute(
    IN p_attribute_id INT, 
    IN p_attribute_name VARCHAR(100), 
    IN p_attribute_description VARCHAR(500), 
    IN p_variant_creation ENUM('Instantly','Never'), 
    IN p_display_type ENUM('Radio','Checkbox'), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_attribute_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_attribute_id IS NULL OR NOT EXISTS (SELECT 1 FROM attribute WHERE attribute_id = p_attribute_id) THEN
        INSERT INTO attribute (
            attribute_name,
            attribute_description,
            variant_creation,
            display_type,
            last_log_by
        ) 
        VALUES(
            p_attribute_name,
            p_attribute_description,
            p_variant_creation,
            p_display_type,
            p_last_log_by
        );
        
        SET v_new_attribute_id = LAST_INSERT_ID();
    ELSE
        UPDATE attribute_value
        SET attribute_name  = p_attribute_name,
            last_log_by     = p_last_log_by
        WHERE attribute_id  = p_attribute_id;

        UPDATE product_attribute
        SET attribute_name  = p_attribute_name,
            last_log_by     = p_last_log_by
        WHERE attribute_id  = p_attribute_id;

        UPDATE product_variant
        SET attribute_name  = p_attribute_name,
            last_log_by     = p_last_log_by
        WHERE attribute_id  = p_attribute_id;

        UPDATE attribute
        SET attribute_name          = p_attribute_name,
            attribute_description   = p_attribute_description,
            variant_creation        = p_variant_creation,
            display_type            = p_display_type,
            last_log_by             = p_last_log_by
        WHERE attribute_id          = p_attribute_id;

        SET v_new_attribute_id = p_attribute_id;
    END IF;

    COMMIT;

    SELECT v_new_attribute_id AS new_attribute_id;
END //

DROP PROCEDURE IF EXISTS saveAttributeValue//

CREATE PROCEDURE saveAttributeValue(
    IN p_attribute_value_id INT, 
    IN p_attribute_value_name VARCHAR(100), 
    IN p_attribute_id INT, 
    IN p_attribute_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_attribute_value_id IS NULL OR NOT EXISTS (SELECT 1 FROM attribute_value WHERE attribute_value_id = p_attribute_value_id) THEN
        INSERT INTO attribute_value (
            attribute_value_name,
            attribute_id,
            attribute_name,
            last_log_by
        ) 
        VALUES(
            p_attribute_value_name,
            p_attribute_id,
            p_attribute_name,
            p_last_log_by
        );
    ELSE
        UPDATE product_attribute
        SET attribute_value_name    = p_attribute_value_name,
            last_log_by             = p_last_log_by
        WHERE attribute_value_id    = p_attribute_value_id;

        UPDATE product_variant
        SET attribute_value_name    = p_attribute_value_name,
            last_log_by             = p_last_log_by
        WHERE attribute_value_id    = p_attribute_value_id;

        UPDATE attribute_value
        SET attribute_value_name    = p_attribute_value_name,
            attribute_id            = p_attribute_id,
            attribute_name          = p_attribute_name,
            last_log_by             = p_last_log_by
        WHERE attribute_value_id    = p_attribute_value_id;
    END IF;

    COMMIT;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchAttribute//

CREATE PROCEDURE fetchAttribute(
    IN p_attribute_id INT
)
BEGIN
	SELECT * FROM attribute
	WHERE attribute_id = p_attribute_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchAttributeValue//

CREATE PROCEDURE fetchAttributeValue(
    IN p_attribute_value_id INT
)
BEGIN
	SELECT * FROM attribute_value
	WHERE attribute_value_id = p_attribute_value_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteAttribute//

CREATE PROCEDURE deleteAttribute(
    IN p_attribute_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM attribute_value WHERE attribute_id = p_attribute_id;
    DELETE FROM attribute WHERE attribute_id = p_attribute_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteAttributeValue//

CREATE PROCEDURE deleteAttributeValue(
    IN p_attribute_value_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM attribute_value WHERE attribute_value_id = p_attribute_value_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkAttributeExist//

CREATE PROCEDURE checkAttributeExist(
    IN p_attribute_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM attribute
    WHERE attribute_id = p_attribute_id;
END //

DROP PROCEDURE IF EXISTS checkAttributeValueExist//

CREATE PROCEDURE checkAttributeValueExist(
    IN p_attribute_value_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM attribute_value
    WHERE attribute_value_id = p_attribute_value_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateAttributeTable//

CREATE PROCEDURE generateAttributeTable(
    IN p_filter_by_variant_creation TEXT,
    IN p_filter_by_display_type TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT attribute_id, attribute_name, attribute_description, variant_creation, display_type 
                FROM attribute ';

    IF p_filter_by_variant_creation IS NOT NULL AND p_filter_by_variant_creation <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' variant_creation IN (', p_filter_by_variant_creation, ')');
    END IF;

    IF p_filter_by_display_type IS NOT NULL AND p_filter_by_display_type <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;
        
        SET filter_conditions = CONCAT(filter_conditions, ' display_type IN (', p_filter_by_display_type, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY attribute_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateAttributeValueTable//

CREATE PROCEDURE generateAttributeValueTable(
    IN p_attribute_id INT
)
BEGIN
	SELECT attribute_value_id, attribute_value_name
    FROM attribute_value 
    WHERE attribute_id = p_attribute_id
    ORDER BY attribute_value_name;
END //

DROP PROCEDURE IF EXISTS generateAttributeOptions//

CREATE PROCEDURE generateAttributeOptions()
BEGIN
	SELECT attribute_id, attribute_name 
    FROM attribute 
    ORDER BY attribute_name;
END //

DROP PROCEDURE IF EXISTS generateAttributeValueOptions//

CREATE PROCEDURE generateAttributeValueOptions()
BEGIN
	SELECT attribute_value_id, attribute_value_name, attribute_id, attribute_name
    FROM attribute_value
    ORDER BY attribute_name ASC, attribute_value_name ASC;
END //

DROP PROCEDURE IF EXISTS generateProductAttributeValueOptions//

CREATE PROCEDURE generateProductAttributeValueOptions(
    IN p_product_id INT
)
BEGIN
	SELECT attribute_value_id, attribute_value_name, attribute_id, attribute_name
    FROM attribute_value
    WHERE attribute_value_id NOT IN (
        SELECT attribute_value_id 
        FROM product_attribute 
        WHERE product_id = p_product_id
    )
    ORDER BY attribute_name ASC, attribute_value_name ASC;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: PRODUCT CATEGORY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveProductCategory//

CREATE PROCEDURE saveProductCategory(
    IN p_product_category_id INT, 
    IN p_product_category_name VARCHAR(100), 
    IN p_parent_category_id INT, 
    IN p_parent_category_name VARCHAR(100), 
    IN p_costing_method ENUM('Average Cost','First In First Out', 'Standard Price'), 
    IN p_display_order INT, 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_product_category_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_product_category_id IS NULL OR NOT EXISTS (SELECT 1 FROM product_category WHERE product_category_id = p_product_category_id) THEN
        INSERT INTO product_category (
            product_category_name,
            parent_category_id,
            parent_category_name,
            costing_method,
            display_order,
            last_log_by
        ) 
        VALUES(
            p_product_category_name,
            p_parent_category_id,
            p_parent_category_name,
            p_costing_method,
            p_display_order,
            p_last_log_by
        );
        
        SET v_new_product_category_id = LAST_INSERT_ID();
    ELSE
        UPDATE product_category_map
        SET product_category_name   = p_product_category_name,
            last_log_by             = p_last_log_by
        WHERE product_category_id   = p_product_category_id;

        UPDATE product_category
        SET product_category_name   = p_product_category_name,
            parent_category_id      = p_parent_category_id,
            parent_category_name    = p_parent_category_name,
            costing_method          = p_costing_method,
            display_order           = p_display_order,
            last_log_by             = p_last_log_by
        WHERE product_category_id   = p_product_category_id;

        SET v_new_product_category_id = p_product_category_id;
    END IF;

    COMMIT;

    SELECT v_new_product_category_id AS new_product_category_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchProductCategory//

CREATE PROCEDURE fetchProductCategory(
    IN p_product_category_id INT
)
BEGIN
	SELECT * FROM product_category
	WHERE product_category_id = p_product_category_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteProductCategory//

CREATE PROCEDURE deleteProductCategory(
    IN p_product_category_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM product_category WHERE product_category_id = p_product_category_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkProductCategoryExist//

CREATE PROCEDURE checkProductCategoryExist(
    IN p_product_category_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM product_category
    WHERE product_category_id = p_product_category_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateProductCategoryTable//

CREATE PROCEDURE generateProductCategoryTable(
    IN p_filter_by_parent_category TEXT,
    IN p_filter_by_costing_method TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT product_category_id, product_category_name, parent_category_name, costing_method, display_order
                FROM product_category';

    IF p_filter_by_parent_category IS NOT NULL AND p_filter_by_parent_category <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' parent_category_id IN (', p_filter_by_parent_category, ')');
    END IF;

    IF p_filter_by_costing_method IS NOT NULL AND p_filter_by_costing_method <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' costing_method IN (', p_filter_by_costing_method, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY product_category_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateProductCategoryOptions//

CREATE PROCEDURE generateProductCategoryOptions()
BEGIN
	SELECT product_category_id, product_category_name 
    FROM product_category 
    ORDER BY product_category_name;
END //

DROP PROCEDURE IF EXISTS generateParentCategoryOptions//

CREATE PROCEDURE generateParentCategoryOptions(
    IN p_product_category_id INT
)
BEGIN
	SELECT product_category_id, product_category_name
    FROM product_category 
    WHERE product_category_id != p_product_category_id
    ORDER BY product_category_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: SUPPLIER
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveSupplier//

CREATE PROCEDURE saveSupplier(
    IN p_supplier_id INT, 
    IN p_supplier_name VARCHAR(200), 
    IN p_contact_person VARCHAR(500), 
    IN p_phone VARCHAR(20), 
    IN p_telephone VARCHAR(20), 
    IN p_email VARCHAR(255), 
    IN p_address VARCHAR(1000), 
    IN p_city_id INT, 
    IN p_city_name VARCHAR(100), 
    IN p_state_id INT, 
    IN p_state_name VARCHAR(100), 
    IN p_country_id INT, 
    IN p_country_name VARCHAR(100), 
    IN p_tax_id_number VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_supplier_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_supplier_id IS NULL OR NOT EXISTS (SELECT 1 FROM supplier WHERE supplier_id = p_supplier_id) THEN
        INSERT INTO supplier (
            supplier_name,
            contact_person,
            phone,
            telephone,
            email,
            address,
            city_id,
            city_name,
            state_id,
            state_name,
            country_id,
            country_name,
            tax_id_number,
            last_log_by
        ) 
        VALUES(
            p_supplier_name,
            p_contact_person,
            p_phone,
            p_telephone,
            p_email,
            p_address,
            p_city_id,
            p_city_name,
            p_state_id,
            p_state_name,
            p_country_id,
            p_country_name,
            p_tax_id_number,
            p_last_log_by
        ); 
        
        SET v_new_supplier_id = LAST_INSERT_ID();
    ELSE        
        UPDATE supplier
        SET supplier_name   = p_supplier_name,
            contact_person  = p_contact_person,
            phone           = p_phone,
            telephone       = p_telephone,
            email           = p_email,
            address         = p_address,
            city_id         = p_city_id,
            city_name       = p_city_name,
            state_id        = p_state_id,
            state_name      = p_state_name,
            country_id      = p_country_id,
            country_name    = p_country_name,
            tax_id_number   = p_tax_id_number,
            last_log_by     = p_last_log_by
        WHERE supplier_id   = p_supplier_id;

        SET v_new_supplier_id = p_supplier_id;
    END IF;

    COMMIT;

    SELECT v_new_supplier_id AS new_supplier_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateSupplierArchive//

CREATE PROCEDURE updateSupplierArchive(
	IN p_supplier_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE supplier
    SET supplier_status     = 'Archived',
        last_log_by         = p_last_log_by
    WHERE supplier_id       = p_supplier_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateSupplierUnarchive//

CREATE PROCEDURE updateSupplierUnarchive(
	IN p_supplier_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE supplier
    SET supplier_status     = 'Active',
        last_log_by         = p_last_log_by
    WHERE supplier_id       = p_supplier_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchSupplier//

CREATE PROCEDURE fetchSupplier(
    IN p_supplier_id INT
)
BEGIN
	SELECT * FROM supplier
	WHERE supplier_id = p_supplier_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteSupplier//

CREATE PROCEDURE deleteSupplier(
    IN p_supplier_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM supplier WHERE supplier_id = p_supplier_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkSupplierExist//

CREATE PROCEDURE checkSupplierExist(
    IN p_supplier_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM supplier
    WHERE supplier_id = p_supplier_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateSupplierTable//

CREATE PROCEDURE generateSupplierTable(
    IN p_filter_by_city TEXT,
    IN p_filter_by_state TEXT,
    IN p_filter_by_country TEXT,
    IN p_filter_by_supplier_status TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT supplier_id, supplier_name, address, city_name, state_name, country_name 
                FROM supplier ';

    IF p_filter_by_city IS NOT NULL AND p_filter_by_city <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' city_id IN (', p_filter_by_city, ')');
    END IF;

    IF p_filter_by_state IS NOT NULL AND p_filter_by_state <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' state_id IN (', p_filter_by_state, ')');
    END IF;

    IF p_filter_by_country IS NOT NULL AND p_filter_by_country <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' country_id IN (', p_filter_by_country, ')');
    END IF;

    IF p_filter_by_supplier_status IS NOT NULL AND p_filter_by_supplier_status <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' supplier_status IN (', p_filter_by_supplier_status, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY supplier_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateSupplierOptions//

CREATE PROCEDURE generateSupplierOptions()
BEGIN
	SELECT supplier_id, supplier_name 
    FROM supplier 
    ORDER BY supplier_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: TAX
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveTax//

CREATE PROCEDURE saveTax(
    IN p_tax_id INT, 
    IN p_tax_name VARCHAR(200), 
    IN p_tax_rate DECIMAL(5,2), 
    IN p_tax_type ENUM('None', 'Purchases','Sales'), 
    IN p_tax_computation ENUM('Fixed','Percentage'), 
    IN p_tax_scope ENUM('Goods','Services'), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_tax_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_tax_id IS NULL OR NOT EXISTS (SELECT 1 FROM tax WHERE tax_id = p_tax_id) THEN
        INSERT INTO tax (
            tax_name,
            tax_rate,
            tax_type,
            tax_computation,
            tax_scope,
            last_log_by
        ) 
        VALUES(
            p_tax_name,
            p_tax_rate,
            p_tax_type,
            p_tax_computation,
            p_tax_scope,
            p_last_log_by
        ); 
        
        SET v_new_tax_id = LAST_INSERT_ID();
    ELSE        
        UPDATE product_tax
        SET tax_name            = p_tax_name,
            last_log_by         = p_last_log_by
        WHERE tax_id            = p_tax_id;

        UPDATE tax
        SET tax_name            = p_tax_name,
            tax_rate            = p_tax_rate,
            tax_type            = p_tax_type,
            tax_computation     = p_tax_computation,
            tax_scope           = p_tax_scope,
            last_log_by         = p_last_log_by
        WHERE tax_id            = p_tax_id;

        SET v_new_tax_id = p_tax_id;
    END IF;

    COMMIT;

    SELECT v_new_tax_id AS new_tax_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateTaxArchive//

CREATE PROCEDURE updateTaxArchive(
	IN p_tax_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE tax
    SET tax_status      = 'Archived',
        last_log_by     = p_last_log_by
    WHERE tax_id        = p_tax_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateTaxUnarchive//

CREATE PROCEDURE updateTaxUnarchive(
	IN p_tax_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE tax
    SET tax_status      = 'Active',
        last_log_by     = p_last_log_by
    WHERE tax_id        = p_tax_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchTax//

CREATE PROCEDURE fetchTax(
    IN p_tax_id INT
)
BEGIN
	SELECT * FROM tax
	WHERE tax_id = p_tax_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteTax//

CREATE PROCEDURE deleteTax(
    IN p_tax_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM tax WHERE tax_id = p_tax_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkTaxExist//

CREATE PROCEDURE checkTaxExist(
    IN p_tax_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM tax
    WHERE tax_id = p_tax_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateTaxTable//

CREATE PROCEDURE generateTaxTable(
    IN p_filter_by_tax_type TEXT,
    IN p_filter_by_tax_computation TEXT,
    IN p_filter_by_tax_scope TEXT,
    IN p_filter_by_tax_status TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT tax_id, tax_name, tax_rate, tax_type, tax_computation, tax_scope 
                FROM tax ';

    IF p_filter_by_tax_type IS NOT NULL AND p_filter_by_tax_type <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' tax_type IN (', p_filter_by_tax_type, ')');
    END IF;

    IF p_filter_by_tax_computation IS NOT NULL AND p_filter_by_tax_computation <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' tax_computation IN (', p_filter_by_tax_computation, ')');
    END IF;

    IF p_filter_by_tax_scope IS NOT NULL AND p_filter_by_tax_scope <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' tax_scope IN (', p_filter_by_tax_scope, ')');
    END IF;

    IF p_filter_by_tax_status IS NOT NULL AND p_filter_by_tax_status <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' tax_status IN (', p_filter_by_tax_status, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY tax_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateTaxOptions//

CREATE PROCEDURE generateTaxOptions()
BEGIN
	SELECT tax_id, tax_name 
    FROM tax 
    ORDER BY tax_name;
END //

DROP PROCEDURE IF EXISTS generateSalesTaxOptions//

CREATE PROCEDURE generateSalesTaxOptions()
BEGIN
	SELECT tax_id, tax_name 
    FROM tax 
    WHERE tax_type = 'Sales'
    ORDER BY tax_name;
END //

DROP PROCEDURE IF EXISTS generatePurchaseTaxOptions//

CREATE PROCEDURE generatePurchaseTaxOptions()
BEGIN
	SELECT tax_id, tax_name 
    FROM tax 
    WHERE tax_type = 'Purchases'
    ORDER BY tax_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: WAREHOUSE TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveWarehouseType//

CREATE PROCEDURE saveWarehouseType(
    IN p_warehouse_type_id INT, 
    IN p_warehouse_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_warehouse_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_warehouse_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM warehouse_type WHERE warehouse_type_id = p_warehouse_type_id) THEN
        INSERT INTO warehouse_type (
            warehouse_type_name,
            last_log_by
        ) 
        VALUES(
            p_warehouse_type_name,
            p_last_log_by
        );
        
        SET v_new_warehouse_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE warehouse
        SET warehouse_type_name     = p_warehouse_type_name,
            last_log_by             = p_last_log_by
        WHERE warehouse_type_id     = p_warehouse_type_id;

        UPDATE warehouse_type
        SET warehouse_type_name     = p_warehouse_type_name,
            last_log_by             = p_last_log_by
        WHERE warehouse_type_id     = p_warehouse_type_id;

        SET v_new_warehouse_type_id = p_warehouse_type_id;
    END IF;

    COMMIT;

    SELECT v_new_warehouse_type_id AS new_warehouse_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchWarehouseType//

CREATE PROCEDURE fetchWarehouseType(
    IN p_warehouse_type_id INT
)
BEGIN
	SELECT * FROM warehouse_type
	WHERE warehouse_type_id = p_warehouse_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteWarehouseType//

CREATE PROCEDURE deleteWarehouseType(
    IN p_warehouse_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM warehouse_type WHERE warehouse_type_id = p_warehouse_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkWarehouseTypeExist//

CREATE PROCEDURE checkWarehouseTypeExist(
    IN p_warehouse_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM warehouse_type
    WHERE warehouse_type_id = p_warehouse_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateWarehouseTypeTable//

CREATE PROCEDURE generateWarehouseTypeTable()
BEGIN
	SELECT warehouse_type_id, warehouse_type_name
    FROM warehouse_type 
    ORDER BY warehouse_type_id;
END //

DROP PROCEDURE IF EXISTS generateWarehouseTypeOptions//

CREATE PROCEDURE generateWarehouseTypeOptions()
BEGIN
	SELECT warehouse_type_id, warehouse_type_name 
    FROM warehouse_type 
    ORDER BY warehouse_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: WAREHOUSE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveWarehouse//

CREATE PROCEDURE saveWarehouse(
    IN p_warehouse_id INT, 
    IN p_warehouse_name VARCHAR(200), 
    IN p_short_name VARCHAR(200), 
    IN p_contact_person VARCHAR(500), 
    IN p_phone VARCHAR(20), 
    IN p_telephone VARCHAR(20), 
    IN p_email VARCHAR(255), 
    IN p_address VARCHAR(1000), 
    IN p_city_id INT, 
    IN p_city_name VARCHAR(100), 
    IN p_state_id INT, 
    IN p_state_name VARCHAR(100), 
    IN p_country_id INT, 
    IN p_country_name VARCHAR(100), 
    IN p_warehouse_type_id INT, 
    IN p_warehouse_type_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_warehouse_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_warehouse_id IS NULL OR NOT EXISTS (SELECT 1 FROM warehouse WHERE warehouse_id = p_warehouse_id) THEN
        INSERT INTO warehouse (
            warehouse_name,
            short_name,
            contact_person,
            phone,
            telephone,
            email,
            address,
            city_id,
            city_name,
            state_id,
            state_name,
            country_id,
            country_name,
            warehouse_type_id,
            warehouse_type_name,
            last_log_by
        ) 
        VALUES(
            p_warehouse_name,
            p_short_name,
            p_contact_person,
            p_phone,
            p_telephone,
            p_email,
            p_address,
            p_city_id,
            p_city_name,
            p_state_id,
            p_state_name,
            p_country_id,
            p_country_name,
            p_warehouse_type_id,
            p_warehouse_type_name,
            p_last_log_by
        ); 
        
        SET v_new_warehouse_id = LAST_INSERT_ID();
    ELSE        
        UPDATE warehouse
        SET warehouse_name          = p_warehouse_name,
            short_name              = p_short_name,
            contact_person          = p_contact_person,
            phone                   = p_phone,
            telephone               = p_telephone,
            email                   = p_email,
            address                 = p_address,
            city_id                 = p_city_id,
            city_name               = p_city_name,
            state_id                = p_state_id,
            state_name              = p_state_name,
            country_id              = p_country_id,
            country_name            = p_country_name,
            warehouse_type_id       = p_warehouse_type_id,
            warehouse_type_name     = p_warehouse_type_name,
            last_log_by             = p_last_log_by
        WHERE warehouse_id          = p_warehouse_id;

        SET v_new_warehouse_id = p_warehouse_id;
    END IF;

    COMMIT;

    SELECT v_new_warehouse_id AS new_warehouse_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateWarehouseArchive//

CREATE PROCEDURE updateWarehouseArchive(
	IN p_warehouse_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE warehouse
    SET warehouse_status    = 'Archived',
        last_log_by         = p_last_log_by
    WHERE warehouse_id      = p_warehouse_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateWarehouseUnarchive//

CREATE PROCEDURE updateWarehouseUnarchive(
	IN p_warehouse_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE warehouse
    SET warehouse_status    = 'Active',
        last_log_by         = p_last_log_by
    WHERE warehouse_id      = p_warehouse_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchWarehouse//

CREATE PROCEDURE fetchWarehouse(
    IN p_warehouse_id INT
)
BEGIN
	SELECT * FROM warehouse
	WHERE warehouse_id = p_warehouse_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteWarehouse//

CREATE PROCEDURE deleteWarehouse(
    IN p_warehouse_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM warehouse WHERE warehouse_id = p_warehouse_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkWarehouseExist//

CREATE PROCEDURE checkWarehouseExist(
    IN p_warehouse_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM warehouse
    WHERE warehouse_id = p_warehouse_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateWarehouseTable//

CREATE PROCEDURE generateWarehouseTable(
    IN p_filter_by_warehouse_type TEXT,
    IN p_filter_by_city TEXT,
    IN p_filter_by_state TEXT,
    IN p_filter_by_country TEXT,
    IN p_filter_by_warehouse_status TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT warehouse_id, warehouse_name, address, city_name, state_name, country_name 
                FROM warehouse ';

    IF p_filter_by_warehouse_type IS NOT NULL AND p_filter_by_warehouse_type <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' warehouse_type_id IN (', p_filter_by_warehouse_type, ')');
    END IF;

    IF p_filter_by_city IS NOT NULL AND p_filter_by_city <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' city_id IN (', p_filter_by_city, ')');
    END IF;

    IF p_filter_by_state IS NOT NULL AND p_filter_by_state <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' state_id IN (', p_filter_by_state, ')');
    END IF;

    IF p_filter_by_country IS NOT NULL AND p_filter_by_country <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' country_id IN (', p_filter_by_country, ')');
    END IF;

    IF p_filter_by_warehouse_status IS NOT NULL AND p_filter_by_warehouse_status <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' warehouse_status IN (', p_filter_by_warehouse_status, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY warehouse_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateWarehouseOptions//

CREATE PROCEDURE generateWarehouseOptions()
BEGIN
	SELECT warehouse_id, warehouse_name 
    FROM warehouse 
    ORDER BY warehouse_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: UNIT TYPE
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveUnitType//

CREATE PROCEDURE saveUnitType(
    IN p_unit_type_id INT, 
    IN p_unit_type_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_unit_type_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_unit_type_id IS NULL OR NOT EXISTS (SELECT 1 FROM unit_type WHERE unit_type_id = p_unit_type_id) THEN
        INSERT INTO unit_type (
            unit_type_name,
            last_log_by
        ) 
        VALUES(
            p_unit_type_name,
            p_last_log_by
        );
        
        SET v_new_unit_type_id = LAST_INSERT_ID();
    ELSE
        UPDATE unit
        SET unit_type_name  = p_unit_type_name,
            last_log_by     = p_last_log_by
        WHERE unit_type_id  = p_unit_type_id;

        UPDATE unit_type
        SET unit_type_name  = p_unit_type_name,
            last_log_by     = p_last_log_by
        WHERE unit_type_id  = p_unit_type_id;

        SET v_new_unit_type_id = p_unit_type_id;
    END IF;

    COMMIT;

    SELECT v_new_unit_type_id AS new_unit_type_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchUnitType//

CREATE PROCEDURE fetchUnitType(
    IN p_unit_type_id INT
)
BEGIN
	SELECT * FROM unit_type
	WHERE unit_type_id = p_unit_type_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteUnitType//

CREATE PROCEDURE deleteUnitType(
    IN p_unit_type_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM unit_type WHERE unit_type_id = p_unit_type_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkUnitTypeExist//

CREATE PROCEDURE checkUnitTypeExist(
    IN p_unit_type_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM unit_type
    WHERE unit_type_id = p_unit_type_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateUnitTypeTable//

CREATE PROCEDURE generateUnitTypeTable()
BEGIN
	SELECT unit_type_id, unit_type_name
    FROM unit_type 
    ORDER BY unit_type_id;
END //

DROP PROCEDURE IF EXISTS generateUnitTypeOptions//

CREATE PROCEDURE generateUnitTypeOptions()
BEGIN
	SELECT unit_type_id, unit_type_name 
    FROM unit_type 
    ORDER BY unit_type_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: UNIT
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveUnit//

CREATE PROCEDURE saveUnit(
    IN p_unit_id INT, 
    IN p_unit_name VARCHAR(200), 
    IN p_unit_abbreviation VARCHAR(20), 
    IN p_unit_type_id INT, 
    IN p_unit_type_name VARCHAR(100), 
    IN p_ratio_to_base DECIMAL(15,6),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_unit_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_unit_id IS NULL OR NOT EXISTS (SELECT 1 FROM unit WHERE unit_id = p_unit_id) THEN
        INSERT INTO unit (
            unit_name,
            unit_abbreviation,
            unit_type_id,
            unit_type_name,
            ratio_to_base,
            last_log_by
        ) 
        VALUES(
            p_unit_name,
            p_unit_abbreviation,
            p_unit_type_id,
            p_unit_type_name,
            p_ratio_to_base,
            p_last_log_by
        ); 
        
        SET v_new_unit_id = LAST_INSERT_ID();
    ELSE        
        UPDATE product
        SET unit_name           = p_unit_name,
            unit_abbreviation   = p_unit_abbreviation,
            last_log_by         = p_last_log_by
        WHERE unit_id           = p_unit_id;

        UPDATE unit
        SET unit_name           = p_unit_name,
            unit_abbreviation   = p_unit_abbreviation,
            unit_type_id        = p_unit_type_id,
            unit_type_name      = p_unit_type_name,
            ratio_to_base       = p_ratio_to_base,
            last_log_by         = p_last_log_by
        WHERE unit_id           = p_unit_id;

        SET v_new_unit_id = p_unit_id;
    END IF;

    COMMIT;

    SELECT v_new_unit_id AS new_unit_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchUnit//

CREATE PROCEDURE fetchUnit(
    IN p_unit_id INT
)
BEGIN
	SELECT * FROM unit
	WHERE unit_id = p_unit_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteUnit//

CREATE PROCEDURE deleteUnit(
    IN p_unit_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM unit WHERE unit_id = p_unit_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkUnitExist//

CREATE PROCEDURE checkUnitExist(
    IN p_unit_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM unit
    WHERE unit_id = p_unit_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateUnitTable//

CREATE PROCEDURE generateUnitTable(
    IN p_filter_by_unit_type TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT unit_id, unit_name, unit_abbreviation, unit_type_name, ratio_to_base 
                FROM unit ';

    IF p_filter_by_unit_type IS NOT NULL AND p_filter_by_unit_type <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' unit_type_id IN (', p_filter_by_unit_type, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY unit_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateUnitOptions//

CREATE PROCEDURE generateUnitOptions()
BEGIN
	SELECT unit_id, unit_name, unit_type_id, unit_type_name, unit_abbreviation
    FROM unit 
    ORDER BY unit_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: PRODUCT
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveSubProductAndVariants//

CREATE PROCEDURE saveSubProductAndVariants(
    IN p_parent_product_id INT,
    IN p_parent_product_name VARCHAR(200),
    IN p_variant_name VARCHAR(255),
    IN p_variant_signature CHAR(40),
    IN p_last_log_by INT
)
BEGIN
    DECLARE existing_id INT;
    DECLARE v_new_subproduct_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT product_id
    INTO existing_id
    FROM product
    WHERE parent_product_id = p_parent_product_id
      AND variant_signature = p_variant_signature
    LIMIT 1;

    IF existing_id IS NULL THEN
        INSERT INTO product (
            parent_product_id,
            parent_product_name,
            product_name,
            product_description,
            product_image,
            product_type,
            sku,
            barcode,
            unit_id,
            unit_name,
            unit_abbreviation,
            cost,
            sales_price,
            is_variant,
            is_sellable,
            is_purchasable,
            show_on_pos,
            weight,
            width,
            height,
            length,
            variant_signature,
            product_status,
            last_log_by
        )
        SELECT
            p_parent_product_id,
            p_parent_product_name,
            p_variant_name,
            p.product_description,
            p.product_image,
            p.product_type,
            NULL,
            NULL,
            p.unit_id,
            p.unit_name,
            p.unit_abbreviation,
            p.cost,
            p.sales_price,
            'Yes',
            p.is_sellable,
            p.is_purchasable,
            p.show_on_pos,
            p.weight,
            p.width,
            p.height,
            p.length,
            p_variant_signature,
            'Active',
            p_last_log_by
        FROM product p
        WHERE p.product_id = p_parent_product_id;

        SET v_new_subproduct_id = LAST_INSERT_ID();

        INSERT INTO product_category_map (
            product_id,
            product_name,
            product_category_id,
            product_category_name,
            last_log_by
        )
        SELECT
            v_new_subproduct_id,
            p_variant_name,
            pcm.product_category_id,
            pcm.product_category_name,
            p_last_log_by
        FROM product_category_map pcm
        WHERE pcm.product_id = p_parent_product_id;

        INSERT INTO product_tax (
            product_id,
            product_name,
            tax_type,
            tax_id,
            tax_name,
            last_log_by
        )
        SELECT
            v_new_subproduct_id,
            p_variant_name,
            pt.tax_type,
            pt.tax_id,
            pt.tax_name,
            p_last_log_by
        FROM product_tax pt
        WHERE pt.product_id = p_parent_product_id;

    ELSE
        -- Reactivate existing variant
        UPDATE product
        SET product_status = 'Active',
            product_name = p_variant_name,
            last_log_by = p_last_log_by
        WHERE product_id = existing_id;

        SET v_new_subproduct_id = existing_id;
    END IF;

    COMMIT;

    SELECT v_new_subproduct_id AS new_subproduct_id;
END //

DROP PROCEDURE IF EXISTS saveProductPricelist//

CREATE PROCEDURE saveProductPricelist(
    IN p_product_pricelist_id INT, 
    IN p_product_id INT, 
    IN p_product_name VARCHAR(200), 
    IN p_discount_type ENUM('Percentage','Fixed Amount'), 
    IN p_fixed_price DECIMAL(10,2), 
    IN p_min_quantity INT,
    IN p_validity_start_date DATE,
    IN p_validity_end_date DATE,
    IN p_remarks VARCHAR(1000),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_product_pricelist_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_product_pricelist_id IS NULL OR NOT EXISTS (SELECT 1 FROM product_pricelist WHERE product_pricelist_id = p_product_pricelist_id) THEN
        INSERT INTO product_pricelist (
            product_id,
            product_name,
            discount_type,
            fixed_price,
            min_quantity,
            validity_start_date,
            validity_end_date,
            remarks,
            last_log_by
        ) 
        VALUES(
            p_product_id,
            p_product_name,
            p_discount_type,
            p_fixed_price,
            p_min_quantity,
            p_validity_start_date,
            p_validity_end_date,
            p_remarks,
            p_last_log_by
        );

        SET v_new_product_pricelist_id = LAST_INSERT_ID();
    ELSE
        UPDATE product_pricelist
        SET product_id              = p_product_id,
            product_name            = p_product_name,
            discount_type           = p_discount_type,
            fixed_price             = p_fixed_price,
            min_quantity            = p_min_quantity,
            validity_start_date     = p_validity_start_date,
            validity_end_date       = p_validity_end_date,
            remarks                 = p_remarks,
            last_log_by             = p_last_log_by
        WHERE product_pricelist_id  = p_product_pricelist_id;

        SET v_new_product_pricelist_id = p_product_pricelist_id;
    END IF;

    COMMIT;

    SELECT v_new_product_pricelist_id AS new_product_pricelist_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS insertProduct//

CREATE PROCEDURE insertProduct(
    IN p_product_name VARCHAR(100),
    IN p_product_description VARCHAR(1000),
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_product_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO product (
        product_name,
        product_description,
        last_log_by
    ) 
    VALUES(
        p_product_name,
        p_product_description,
        p_last_log_by
    );

    SET v_new_product_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_new_product_id AS new_product_id;
END //

DROP PROCEDURE IF EXISTS insertproductCategoryMap//

CREATE PROCEDURE insertproductCategoryMap(
    IN p_product_id INT, 
    IN p_product_name VARCHAR(100), 
    IN p_product_category_id INT, 
    IN p_product_category_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO product_category_map (
        product_id,
        product_name,
        product_category_id,
        product_category_name,
        last_log_by
    ) 
    VALUES(
        p_product_id,
        p_product_name,
        p_product_category_id,
        p_product_category_name,
        p_last_log_by
    );

    COMMIT;
END //

DROP PROCEDURE IF EXISTS insertProductTax//

CREATE PROCEDURE insertProductTax(
    IN p_product_id INT, 
    IN p_product_name VARCHAR(100), 
    IN p_tax_type VARCHAR(50), 
    IN p_tax_id INT, 
    IN p_tax_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO product_tax (
        product_id,
        product_name,
        tax_type,
        tax_id,
        tax_name,
        last_log_by
    ) 
    VALUES(
        p_product_id,
        p_product_name,
        p_tax_type,
        p_tax_id,
        p_tax_name,
        p_last_log_by
    );

    COMMIT;
END //

DROP PROCEDURE IF EXISTS insertProductAttribute//

CREATE PROCEDURE insertProductAttribute(
    IN p_product_id INT, 
    IN p_product_name VARCHAR(100), 
    IN p_attribute_id INT, 
    IN p_attribute_name VARCHAR(100), 
    IN p_attribute_value_id INT, 
    IN p_attribute_value_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO product_attribute (
        product_id,
        product_name,
        attribute_id,
        attribute_name,
        attribute_value_id,
        attribute_value_name,
        last_log_by
    ) 
    VALUES(
        p_product_id,
        p_product_name,
        p_attribute_id,
        p_attribute_name,
        p_attribute_value_id,
        p_attribute_value_name,
        p_last_log_by
    );

    COMMIT;
END //

DROP PROCEDURE IF EXISTS insertProductVariant //

CREATE PROCEDURE insertProductVariant(
    IN p_parent_product_id INT,
    IN p_parent_product_name VARCHAR(200),
    IN p_product_id INT,
    IN p_product_name VARCHAR(200),
    IN p_attribute_id INT,
    IN p_attribute_name VARCHAR(100),
    IN p_attribute_value_id INT,
    IN p_attribute_value_name VARCHAR(100),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO product_variant (
        parent_product_id,
        parent_product_name,
        product_id,
        product_name,
        attribute_id,
        attribute_name,
        attribute_value_id,
        attribute_value_name,
        last_log_by
    )
    VALUES (
        p_parent_product_id,
        p_parent_product_name,
        p_product_id,
        p_product_name,
        p_attribute_id,
        p_attribute_name,
        p_attribute_value_id,
        p_attribute_value_name,
        p_last_log_by
    );

    COMMIT;
END //

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updateProductGeneral//

CREATE PROCEDURE updateProductGeneral(
	IN p_product_id INT, 
	IN p_product_name VARCHAR(100), 
	IN p_product_description VARCHAR(1000), 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET parent_product_name     = p_product_name,
        last_log_by             = p_last_log_by
    WHERE parent_product_id     = p_product_id;

    UPDATE product_tax
    SET product_name            = p_product_name,
        last_log_by             = p_last_log_by
    WHERE product_id            = p_product_id;
    
    UPDATE product_category_map
    SET product_name            = p_product_name,
        last_log_by             = p_last_log_by
    WHERE product_id            = p_product_id;
    
    UPDATE product_attribute
    SET product_name            = p_product_name,
        last_log_by             = p_last_log_by
    WHERE product_id            = p_product_id;
    
    UPDATE product_variant
    SET product_name            = p_product_name,
        last_log_by             = p_last_log_by
    WHERE product_id            = p_product_id;
    
    UPDATE product_variant
    SET parent_product_name     = p_product_name,
        last_log_by             = p_last_log_by
    WHERE parent_product_id     = p_product_id;
    
    UPDATE product_pricelist
    SET product_name            = p_product_name,
        last_log_by             = p_last_log_by
    WHERE product_id            = p_product_id;

    UPDATE product
    SET product_name            = p_product_name,
        product_description     = p_product_description,
        last_log_by             = p_last_log_by
    WHERE product_id            = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateProductInventory//

CREATE PROCEDURE updateProductInventory(
	IN p_product_id INT, 
	IN p_sku VARCHAR(200), 
	IN p_barcode VARCHAR(200), 
	IN p_product_type ENUM('Goods','Services', 'Combo'), 
	IN p_quantity_on_hand DECIMAL(15,4), 
	IN p_unit_id INT, 
	IN p_unit_name VARCHAR(100), 
	IN p_unit_abbreviation VARCHAR(20), 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET sku                 = p_sku,
        barcode             = p_barcode,
        product_type        = p_product_type,
        quantity_on_hand    = p_quantity_on_hand,
        unit_id             = p_unit_id,
        unit_name           = p_unit_name,
        unit_abbreviation   = p_unit_abbreviation,
        last_log_by         = p_last_log_by
    WHERE product_id        = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateProductPricing//

CREATE PROCEDURE updateProductPricing(
	IN p_product_id INT, 
	IN p_sales_price DECIMAL(15,2),
	IN p_cost DECIMAL(15,2),
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET sales_price     = p_sales_price,
        cost            = p_cost,
        last_log_by     = p_last_log_by
    WHERE product_id    = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateProductShipping//

CREATE PROCEDURE updateProductShipping(
	IN p_product_id INT, 
	IN p_weight DECIMAL(10,2), 
	IN p_width DECIMAL(10,2), 
	IN p_height DECIMAL(10,2), 
	IN p_length DECIMAL(10,2), 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET weight          = p_weight,
        width           = p_width,
        height          = p_height,
        length          = p_length,
        last_log_by     = p_last_log_by
    WHERE product_id    = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateProductArchive//

CREATE PROCEDURE updateProductArchive(
	IN p_product_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET product_status  = 'Archived',
        last_log_by     = p_last_log_by
    WHERE product_id    = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateProductUnarchive//

CREATE PROCEDURE updateProductUnarchive(
	IN p_product_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET product_status  = 'Active',
        last_log_by     = p_last_log_by
    WHERE product_id    = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateAllSubProductsDeactivate//

CREATE PROCEDURE updateAllSubProductsDeactivate(
	IN p_parent_product_id INT, 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET product_status = 'Archived'
    WHERE parent_product_id = p_parent_product_id
    AND is_variant = 'Yes'
    AND variant_signature IS NOT NULL
    AND product_status = 'Active';

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateProductImage//

CREATE PROCEDURE updateProductImage(
	IN p_product_id INT, 
	IN p_product_image VARCHAR(500), 
	IN p_last_log_by INT
)
BEGIN
 	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE product
    SET product_image   = p_product_image,
        last_log_by     = p_last_log_by
    WHERE product_id    = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS updateProductSettings //

CREATE PROCEDURE updateProductSettings (
    IN p_product_id INT, 
    IN p_value VARCHAR(500),
    IN p_update_type VARCHAR(50),
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    CASE p_update_type
        WHEN 'is sellable' THEN
            UPDATE product
            SET is_sellable     = p_value,
                last_log_by     = p_last_log_by
            WHERE product_id    = p_product_id;

        WHEN 'is purchasable' THEN
            UPDATE product
            SET is_purchasable  = p_value,
                last_log_by     = p_last_log_by
            WHERE product_id    = p_product_id;

        ELSE
            UPDATE product
            SET show_on_pos     = p_value,
                last_log_by     = p_last_log_by
            WHERE product_id    = p_product_id;
    END CASE;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchProduct//

CREATE PROCEDURE fetchProduct(
    IN p_product_id INT
)
BEGIN
	SELECT * FROM product
	WHERE product_id = p_product_id
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchAllProductSubProduct//

CREATE PROCEDURE fetchAllProductSubProduct(
    IN p_product_id INT
)
BEGIN
	SELECT * FROM product
	WHERE parent_product_id = p_product_id;
END //

DROP PROCEDURE IF EXISTS fetchproductCategoryMap//

CREATE PROCEDURE fetchproductCategoryMap(
	IN p_product_id INT
)
BEGIN
	SELECT * FROM product_category_map
	WHERE product_id = p_product_id;
END //

DROP PROCEDURE IF EXISTS fetchProductTax//

CREATE PROCEDURE fetchProductTax(
	IN p_product_id INT,
    IN p_tax_type VARCHAR(50)
)
BEGIN
	SELECT * FROM product_tax
	WHERE product_id = p_product_id AND tax_type = p_tax_type;
END //

DROP PROCEDURE IF EXISTS fetchProductAttribute//

CREATE PROCEDURE fetchProductAttribute(
	IN p_product_attribute INT
)
BEGIN
	SELECT * FROM product_attribute
    WHERE product_attribute_id = p_product_attribute
    LIMIT 1;
END //

DROP PROCEDURE IF EXISTS fetchAllProductAttributes//

CREATE PROCEDURE fetchAllProductAttributes(
	IN p_product_id INT,
    IN p_creation_type ENUM('Instantly','Never')
)
BEGIN
	SELECT 
        pa.attribute_id AS attribute_id,
        pa.attribute_name AS attribute_name,
        pa.attribute_value_id AS attribute_value_id,
        pa.attribute_value_name AS attribute_value_name
    FROM product_attribute pa
    JOIN attribute a ON pa.attribute_id = a.attribute_id
    WHERE pa.product_id = p_product_id
    AND a.variant_creation = p_creation_type
    ORDER BY pa.attribute_id;
END //

DROP PROCEDURE IF EXISTS fetchProductPricelist//

CREATE PROCEDURE fetchProductPricelist(
	IN p_product_pricelist_id INT
)
BEGIN
	SELECT * FROM product_pricelist
    WHERE product_pricelist_id = p_product_pricelist_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteProduct //

CREATE PROCEDURE deleteProduct (
    IN p_product_id INT UNSIGNED
)
BEGIN    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM product_pricelist
    WHERE product_id = p_product_id;

    DELETE FROM product_variant
    WHERE product_id = p_product_id;

    DELETE FROM product_attribute
    WHERE product_id = p_product_id;

    DELETE FROM product_category_map
    WHERE product_id = p_product_id;

    DELETE FROM product_tax
    WHERE product_id = p_product_id;

    DELETE FROM product
    WHERE product_id = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteproductCategoryMap//

CREATE PROCEDURE deleteproductCategoryMap(
    IN p_product_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM product_category_map 
    WHERE product_id = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteProductTax//

CREATE PROCEDURE deleteProductTax(
    IN p_product_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM product_tax 
    WHERE product_id = p_product_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteProductAttribute//

CREATE PROCEDURE deleteProductAttribute(
    IN p_product_attribute_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM product_attribute 
    WHERE product_attribute_id = p_product_attribute_id;

    COMMIT;
END //

DROP PROCEDURE IF EXISTS deleteProductPricelist//

CREATE PROCEDURE deleteProductPricelist(
    IN p_product_pricelist_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM product_pricelist 
    WHERE product_pricelist_id = p_product_pricelist_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkProductExist//

CREATE PROCEDURE checkProductExist(
    IN p_product_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM product
    WHERE product_id = p_product_id;
END //

DROP PROCEDURE IF EXISTS checkProductSKUExist//

CREATE PROCEDURE checkProductSKUExist(
	IN p_product_id INT,
    IN p_sku VARCHAR(200)
)
BEGIN
	SELECT COUNT(*) AS total
    FROM product
    WHERE product_id != p_product_id 
    AND sku = p_sku;
END //

DROP PROCEDURE IF EXISTS checkProductBarcodeExist//

CREATE PROCEDURE checkProductBarcodeExist(
	IN p_product_id INT,
    IN p_barcode VARCHAR(200)
)
BEGIN
	SELECT COUNT(*) AS total
    FROM product
    WHERE product_id != p_product_id 
    AND barcode = p_barcode;
END //

DROP PROCEDURE IF EXISTS checkProductVariantExists //

CREATE PROCEDURE checkProductVariantExists (
	IN p_subproduct_id INT,
    IN p_attribute_value_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM product_variant
    WHERE product_id = p_subproduct_id
    AND attribute_value_id = p_attribute_value_id;
END //

DROP PROCEDURE IF EXISTS checkProductPricelistExists //

CREATE PROCEDURE checkProductgenerateProductOptionsExists (
	IN p_product_pricelist_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM product_pricelist
    WHERE product_pricelist_id = p_product_pricelist_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateProductCard//

CREATE PROCEDURE generateProductCard(
    IN p_search_value TEXT,
    IN p_filter_by_product_type TEXT,
    IN p_filter_by_product_category TEXT,
    IN p_filter_by_is_sellable TEXT,
    IN p_filter_by_is_purchasable TEXT,
    IN p_filter_by_show_on_pos TEXT,
    IN p_filter_by_product_status TEXT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    DECLARE query TEXT;

    -- Base query
    SET query = 'SELECT product_id, product_image, product_name, product_description, product_type, sku, barcode, is_sellable, is_purchasable, show_on_pos, quantity_on_hand, sales_price, cost, product_status
                FROM product
                WHERE is_variant = "No"';

    -- Search filter
    IF p_search_value IS NOT NULL AND p_search_value <> '' THEN
        SET query = CONCAT(query, ' 
            AND (
                product_name LIKE ? OR
                product_description LIKE ? OR
                sku LIKE ? OR
                barcode LIKE ?
            )');
    END IF;

    -- Dynamic filters
    IF p_filter_by_product_type IS NOT NULL AND p_filter_by_product_type <> '' THEN
        SET query = CONCAT(query, ' AND product_type IN (', p_filter_by_product_type, ')');
    END IF;

    IF p_filter_by_product_category IS NOT NULL AND p_filter_by_product_category <> '' THEN
        SET query = CONCAT(query, ' AND product_id IN (SELECT product_id FROM product_category_map WHERE product_category_id IN (', p_filter_by_product_category, '))');
    END IF;

    IF p_filter_by_is_sellable IS NOT NULL AND p_filter_by_is_sellable <> '' THEN
        SET query = CONCAT(query, ' AND is_sellable IN (', p_filter_by_is_sellable, ')');
    END IF;

    IF p_filter_by_is_purchasable IS NOT NULL AND p_filter_by_is_purchasable <> '' THEN
        SET query = CONCAT(query, ' AND is_purchasable IN (', p_filter_by_is_purchasable, ')');
    END IF;

    IF p_filter_by_show_on_pos IS NOT NULL AND p_filter_by_show_on_pos <> '' THEN
        SET query = CONCAT(query, ' AND show_on_pos IN (', p_filter_by_show_on_pos, ')');
    END IF;

    IF p_filter_by_product_status IS NOT NULL AND p_filter_by_product_status <> '' THEN
        SET query = CONCAT(query, ' AND product_status IN (', p_filter_by_product_status, ')');
    END IF;

    -- Final ordering + limit
    SET query = CONCAT(query, ' ORDER BY product_name LIMIT ?, ?');

    PREPARE stmt FROM query;

    -- Bind parameters for search + pagination
    IF p_search_value IS NOT NULL AND p_search_value <> '' THEN
        SET @s1 = CONCAT('%', p_search_value, '%');
        SET @s2 = @s1; SET @s3 = @s1; SET @s4 = @s1;
        SET @offset = p_offset;
        SET @limit  = p_limit;

        EXECUTE stmt USING @s1, @s2, @s3, @s4, @offset, @limit;
    ELSE
        SET @offset = p_offset;
        SET @limit  = p_limit;

        EXECUTE stmt USING @offset, @limit;
    END IF;

    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateProductTable//

CREATE PROCEDURE generateProductTable(
    IN p_filter_by_product_type TEXT,
    IN p_filter_by_product_category TEXT,
    IN p_filter_by_is_sellable TEXT,
    IN p_filter_by_is_purchasable TEXT,
    IN p_filter_by_show_on_pos TEXT,
    IN p_filter_by_product_status TEXT
)
BEGIN
    DECLARE query TEXT DEFAULT 
        'SELECT product_id, product_image, product_name, product_description, product_type, sku, barcode, is_sellable, is_purchasable, show_on_pos, quantity_on_hand, sales_price, cost, product_status
        FROM product WHERE is_variant = "No"';

     IF p_filter_by_product_type IS NOT NULL AND p_filter_by_product_type <> '' THEN
        SET query = CONCAT(query, ' AND product_type IN (', p_filter_by_product_type, ')');
    END IF;

    IF p_filter_by_product_category IS NOT NULL AND p_filter_by_product_category <> '' THEN
        SET query = CONCAT(query, ' AND product_id IN (SELECT product_id FROM product_category_map WHERE product_category_id IN (', p_filter_by_product_category, '))');
    END IF;

    IF p_filter_by_is_sellable IS NOT NULL AND p_filter_by_is_sellable <> '' THEN
        SET query = CONCAT(query, ' AND is_sellable IN (', p_filter_by_is_sellable, ')');
    END IF;

    IF p_filter_by_is_purchasable IS NOT NULL AND p_filter_by_is_purchasable <> '' THEN
        SET query = CONCAT(query, ' AND is_purchasable IN (', p_filter_by_is_purchasable, ')');
    END IF;

    IF p_filter_by_show_on_pos IS NOT NULL AND p_filter_by_show_on_pos <> '' THEN
        SET query = CONCAT(query, ' AND show_on_pos IN (', p_filter_by_show_on_pos, ')');
    END IF;

    IF p_filter_by_product_status IS NOT NULL AND p_filter_by_product_status <> '' THEN
        SET query = CONCAT(query, ' AND product_status IN (', p_filter_by_product_status, ')');
    END IF;

    SET query = CONCAT(query, ' ORDER BY product_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateProductVariantCard//

CREATE PROCEDURE generateProductVariantCard(
    IN p_search_value TEXT,
    IN p_filter_by_product_type TEXT,
    IN p_filter_by_product_category TEXT,
    IN p_filter_by_is_sellable TEXT,
    IN p_filter_by_is_purchasable TEXT,
    IN p_filter_by_show_on_pos TEXT,
    IN p_filter_by_product_status TEXT,
    IN p_limit INT,
    IN p_offset INT
)
BEGIN
    DECLARE query TEXT;

    -- Base query
    SET query = 'SELECT product_id, product_image, product_name, product_description, product_type, sku, barcode, is_sellable, is_purchasable, show_on_pos, quantity_on_hand, sales_price, cost, product_status
                FROM product
                WHERE is_variant = "Yes"';

    -- Search filter
    IF p_search_value IS NOT NULL AND p_search_value <> '' THEN
        SET query = CONCAT(query, ' 
            AND (
                product_name LIKE ? OR
                product_description LIKE ? OR
                sku LIKE ? OR
                barcode LIKE ?
            )');
    END IF;

    -- Dynamic filters
    IF p_filter_by_product_type IS NOT NULL AND p_filter_by_product_type <> '' THEN
        SET query = CONCAT(query, ' AND product_type IN (', p_filter_by_product_type, ')');
    END IF;

    IF p_filter_by_product_category IS NOT NULL AND p_filter_by_product_category <> '' THEN
        SET query = CONCAT(query, ' AND product_id IN (SELECT product_id FROM product_category_map WHERE product_category_id IN (', p_filter_by_product_category, '))');
    END IF;

    IF p_filter_by_is_sellable IS NOT NULL AND p_filter_by_is_sellable <> '' THEN
        SET query = CONCAT(query, ' AND is_sellable IN (', p_filter_by_is_sellable, ')');
    END IF;

    IF p_filter_by_is_purchasable IS NOT NULL AND p_filter_by_is_purchasable <> '' THEN
        SET query = CONCAT(query, ' AND is_purchasable IN (', p_filter_by_is_purchasable, ')');
    END IF;

    IF p_filter_by_show_on_pos IS NOT NULL AND p_filter_by_show_on_pos <> '' THEN
        SET query = CONCAT(query, ' AND show_on_pos IN (', p_filter_by_show_on_pos, ')');
    END IF;

    IF p_filter_by_product_status IS NOT NULL AND p_filter_by_product_status <> '' THEN
        SET query = CONCAT(query, ' AND product_status IN (', p_filter_by_product_status, ')');
    END IF;

    -- Final ordering + limit
    SET query = CONCAT(query, ' ORDER BY product_name LIMIT ?, ?');

    PREPARE stmt FROM query;

    -- Bind parameters for search + pagination
    IF p_search_value IS NOT NULL AND p_search_value <> '' THEN
        SET @s1 = CONCAT('%', p_search_value, '%');
        SET @s2 = @s1; SET @s3 = @s1; SET @s4 = @s1;
        SET @offset = p_offset;
        SET @limit  = p_limit;

        EXECUTE stmt USING @s1, @s2, @s3, @s4, @offset, @limit;
    ELSE
        SET @offset = p_offset;
        SET @limit  = p_limit;

        EXECUTE stmt USING @offset, @limit;
    END IF;

    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateProductVariantTable//

CREATE PROCEDURE generateProductVariantTable(
    IN p_filter_by_product_type TEXT,
    IN p_filter_by_product_category TEXT,
    IN p_filter_by_is_sellable TEXT,
    IN p_filter_by_is_purchasable TEXT,
    IN p_filter_by_show_on_pos TEXT,
    IN p_filter_by_product_status TEXT
)
BEGIN
    DECLARE query TEXT DEFAULT 
        'SELECT product_id, product_image, product_name, product_description, product_type, sku, barcode, is_sellable, is_purchasable, show_on_pos, quantity_on_hand, sales_price, cost, product_status
        FROM product WHERE is_variant = "Yes"';

     IF p_filter_by_product_type IS NOT NULL AND p_filter_by_product_type <> '' THEN
        SET query = CONCAT(query, ' AND product_type IN (', p_filter_by_product_type, ')');
    END IF;

    IF p_filter_by_product_category IS NOT NULL AND p_filter_by_product_category <> '' THEN
        SET query = CONCAT(query, ' AND product_id IN (SELECT product_id FROM product_category_map WHERE product_category_id IN (', p_filter_by_product_category, '))');
    END IF;

    IF p_filter_by_is_sellable IS NOT NULL AND p_filter_by_is_sellable <> '' THEN
        SET query = CONCAT(query, ' AND is_sellable IN (', p_filter_by_is_sellable, ')');
    END IF;

    IF p_filter_by_is_purchasable IS NOT NULL AND p_filter_by_is_purchasable <> '' THEN
        SET query = CONCAT(query, ' AND is_purchasable IN (', p_filter_by_is_purchasable, ')');
    END IF;

    IF p_filter_by_show_on_pos IS NOT NULL AND p_filter_by_show_on_pos <> '' THEN
        SET query = CONCAT(query, ' AND show_on_pos IN (', p_filter_by_show_on_pos, ')');
    END IF;

    IF p_filter_by_product_status IS NOT NULL AND p_filter_by_product_status <> '' THEN
        SET query = CONCAT(query, ' AND product_status IN (', p_filter_by_product_status, ')');
    END IF;

    SET query = CONCAT(query, ' ORDER BY product_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generatePricelistTable//

CREATE PROCEDURE generatePricelistTable(
    IN p_filter_by_product TEXT,
    IN p_filter_by_discount_type TEXT
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT product_pricelist_id, product_name, discount_type, fixed_price, min_quantity, validity_start_date, validity_end_date, remarks
                FROM product_pricelist ';

    IF p_filter_by_product IS NOT NULL AND p_filter_by_product <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' product_id IN (', p_filter_by_product, ')');
    END IF;

    IF p_filter_by_discount_type IS NOT NULL AND p_filter_by_discount_type <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' discount_type IN (', p_filter_by_discount_type, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY product_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generateProductAttributeTable//

CREATE PROCEDURE generateProductAttributeTable(
    IN p_product_id INT
)
BEGIN
    SELECT product_attribute_id, attribute_name, attribute_value_name
    FROM product_attribute
    WHERE product_id = p_product_id;
END //

DROP PROCEDURE IF EXISTS generateProductVariationTable//

CREATE PROCEDURE generateProductVariationTable(
    IN p_product_id INT
)
BEGIN
    SELECT product_id, product_name
    FROM product 
    WHERE is_variant = "Yes"
    AND product_status = "Active"
    AND parent_product_id = p_product_id;
END //

DROP PROCEDURE IF EXISTS generateProductPricelistTable//

CREATE PROCEDURE generateProductPricelistTable(
    IN p_product_id INT
)
BEGIN
    SELECT product_pricelist_id, discount_type, fixed_price, min_quantity, validity_start_date, validity_end_date, remarks
    FROM product_pricelist
    WHERE product_id = p_product_id;
END //

DROP PROCEDURE IF EXISTS generateProductOptions//

CREATE PROCEDURE generateProductOptions()
BEGIN
	SELECT product_id, product_name 
    FROM product 
    ORDER BY product_name;
END //

DROP PROCEDURE IF EXISTS generateActiveProductOptions//

CREATE PROCEDURE generateActiveProductOptions()
BEGIN
	SELECT product_id, product_name 
    FROM product 
    WHERE product_status = 'Active'
    ORDER BY product_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: SCRAP REASON
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS saveScrapReason//

CREATE PROCEDURE saveScrapReason(
    IN p_scrap_reason_id INT, 
    IN p_scrap_reason_name VARCHAR(100), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_scrap_reason_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    IF p_scrap_reason_id IS NULL OR NOT EXISTS (SELECT 1 FROM scrap_reason WHERE scrap_reason_id = p_scrap_reason_id) THEN
        INSERT INTO scrap_reason (
            scrap_reason_name,
            last_log_by
        ) 
        VALUES(
            p_scrap_reason_name,
            p_last_log_by
        );
        
        SET v_new_scrap_reason_id = LAST_INSERT_ID();
    ELSE
        UPDATE inventory_scrap
        SET scrap_reason_name   = p_scrap_reason_name,
            last_log_by         = p_last_log_by
        WHERE scrap_reason_id   = p_scrap_reason_id;
        
        UPDATE scrap_reason
        SET scrap_reason_name   = p_scrap_reason_name,
            last_log_by         = p_last_log_by
        WHERE scrap_reason_id   = p_scrap_reason_id;

        SET v_new_scrap_reason_id = p_scrap_reason_id;
    END IF;

    COMMIT;

    SELECT v_new_scrap_reason_id AS new_scrap_reason_id;
END //

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchScrapReason//

CREATE PROCEDURE fetchScrapReason(
    IN p_scrap_reason_id INT
)
BEGIN
	SELECT * FROM scrap_reason
	WHERE scrap_reason_id = p_scrap_reason_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deleteScrapReason//

CREATE PROCEDURE deleteScrapReason(
    IN p_scrap_reason_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM scrap_reason
    WHERE scrap_reason_id = p_scrap_reason_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkScrapReasonExist//

CREATE PROCEDURE checkScrapReasonExist(
    IN p_scrap_reason_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM scrap_reason
    WHERE scrap_reason_id = p_scrap_reason_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generateScrapReasonTable//

CREATE PROCEDURE generateScrapReasonTable()
BEGIN
	SELECT scrap_reason_id, scrap_reason_name
    FROM scrap_reason 
    ORDER BY scrap_reason_id;
END //

DROP PROCEDURE IF EXISTS generateScrapReasonOptions//

CREATE PROCEDURE generateScrapReasonOptions()
BEGIN
	SELECT scrap_reason_id, scrap_reason_name 
    FROM scrap_reason 
    ORDER BY scrap_reason_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: PHYSICAL INVENTORY
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS insertPhysicalInventory//

CREATE PROCEDURE insertPhysicalInventory(
    IN p_product_id INT, 
    IN p_product_name VARCHAR(200), 
    IN p_quantity_on_hand DECIMAL(15,4), 
    IN p_inventory_date DATE, 
    IN p_remarks VARCHAR(1000), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE v_new_physical_inventory_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO physical_inventory (
        product_id,
        product_name,
        quantity_on_hand,
        inventory_date,
        remarks,
        last_log_by
    ) 
    VALUES(
        p_product_id,
        p_product_name,
        p_quantity_on_hand,
        p_inventory_date,
        p_remarks,
        p_last_log_by
    );
        
    SET v_new_physical_inventory_id = LAST_INSERT_ID();

    COMMIT;

    SELECT v_new_physical_inventory_id AS new_physical_inventory_id;
END //

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

DROP PROCEDURE IF EXISTS updatePhysicalInventory//

CREATE PROCEDURE updatePhysicalInventory(
    IN p_physical_inventory_id INT, 
    IN p_inventory_count DECIMAL(15,4), 
    IN p_inventory_difference DECIMAL(15,4), 
    IN p_inventory_date DATE, 
    IN p_remarks VARCHAR(1000), 
    IN p_last_log_by INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE physical_inventory
    SET inventory_count             = p_inventory_count,
        inventory_difference        = p_inventory_difference,
        inventory_date              = p_inventory_date,
        remarks                     = p_remarks
    WHERE p_physical_inventory_id   = p_physical_inventory_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS fetchPhysicalInventory//

CREATE PROCEDURE fetchPhysicalInventory(
    IN p_physical_inventory_id INT
)
BEGIN
	SELECT * FROM physical_inventory
	WHERE physical_inventory_id = p_physical_inventory_id
    LIMIT 1;
END //

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS deletePhysicalInventory//

CREATE PROCEDURE deletePhysicalInventory(
    IN p_physical_inventory_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    DELETE FROM physical_inventory WHERE physical_inventory_id = p_physical_inventory_id;

    COMMIT;
END //

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS checkPhysicalInventoryExist//

CREATE PROCEDURE checkPhysicalInventoryExist(
    IN p_physical_inventory_id INT
)
BEGIN
	SELECT COUNT(*) AS total
    FROM physical_inventory
    WHERE physical_inventory_id = p_physical_inventory_id;
END //

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

DROP PROCEDURE IF EXISTS generatePhysicalInventoryTable//

CREATE PROCEDURE generatePhysicalInventoryTable(
    IN p_product_id TEXT,
    IN p_inventory_start_date DATE,
    IN p_inventory_end_date DATE,
    IN p_physical_inventory_status TEXT,
)
BEGIN
    DECLARE query TEXT;
    DECLARE filter_conditions TEXT DEFAULT '';

    SET query = 'SELECT physical_inventory_id, product_name, physical_inventory_status, quantity_on_hand, inventory_count, inventory_difference, inventory_date
                FROM physical_inventory';

    IF p_product_id IS NOT NULL AND p_product_id <> '' THEN
        SET filter_conditions = CONCAT(filter_conditions, ' product_id IN (', p_product_id, ')');
    END IF;

    IF physical_inventory_status IS NOT NULL AND physical_inventory_status <> '' THEN
        IF filter_conditions <> '' THEN
            SET filter_conditions = CONCAT(filter_conditions, ' AND ');
        END IF;

        SET filter_conditions = CONCAT(filter_conditions, ' physical_inventory_status IN (', p_physical_inventory_status, ')');
    END IF;

    IF filter_conditions <> '' THEN
        SET query = CONCAT(query, ' WHERE ', filter_conditions);
    END IF;

    SET query = CONCAT(query, ' ORDER BY product_name');

    PREPARE stmt FROM query;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DROP PROCEDURE IF EXISTS generatePhysicalInventoryOptions//

CREATE PROCEDURE generatePhysicalInventoryOptions()
BEGIN
	SELECT product_category_id, product_category_name 
    FROM product_category 
    ORDER BY product_category_name;
END //

DROP PROCEDURE IF EXISTS generateParentCategoryOptions//

CREATE PROCEDURE generateParentCategoryOptions(
    IN p_product_category_id INT
)
BEGIN
	SELECT product_category_id, product_category_name
    FROM product_category 
    WHERE product_category_id != p_product_category_id
    ORDER BY product_category_name;
END //

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */



/* =============================================================================================
   STORED PROCEDURE: 
============================================================================================= */

/* =============================================================================================
   SECTION 1: SAVE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 2: INSERT PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 3: UPDATE PROCEDURES
=============================================================================================  */

/* =============================================================================================
   SECTION 4: FETCH PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 5: DELETE PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 6: CHECK PROCEDURES
============================================================================================= */

/* =============================================================================================
   SECTION 7: GENERATE PROCEDURES
============================================================================================= */

/* =============================================================================================
   END OF PROCEDURES
============================================================================================= */