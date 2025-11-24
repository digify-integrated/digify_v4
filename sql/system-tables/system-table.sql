/* =============================================================================================
  TABLE: USER ACCOUNT
============================================================================================= */

DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
  tenant_id INT NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  mobile VARCHAR(20) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  profile_name VARCHAR(500) NOT NULL,
  profile_picture VARCHAR(500),
  is_active ENUM('No', 'Yes') DEFAULT 'No',
  two_factor_enabled ENUM('No', 'Yes') DEFAULT 'Yes',
  last_connection_date DATETIME,
  last_failed_connection_date DATETIME,
  last_password_change DATETIME,
  last_password_reset_request DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,     
  last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

/* =============================================================================================
  INDEX: USER ACCOUNT
============================================================================================= */

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_mobile ON users(mobile);

/* =============================================================================================
  INITIAL VALUES: USER ACCOUNT
============================================================================================= */

/* =============================================================================================
  END OF TABLE DEFINITIONS
============================================================================================= */


/* =============================================================================================
  TABLE: EMAIL VERIFICATION TOKEN
============================================================================================= */

DROP TABLE IF EXISTS email_verification_token;

CREATE TABLE email_verification_token (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

/* =============================================================================================
  INDEX: EMAIL VERIFICATION TOKEN
============================================================================================= */

CREATE INDEX idx_email_verification_token_user_id ON email_verification_token(user_id);

/* =============================================================================================
  INITIAL VALUES: EMAIL VERIFICATION TOKEN
============================================================================================= */

/* =============================================================================================
  END OF TABLE DEFINITIONS
============================================================================================= */


/* =============================================================================================
  TABLE: USER 2FA TOKEN
============================================================================================= */

DROP TABLE IF EXISTS user_2fa_token;

CREATE TABLE user_2fa_token (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token VARCHAR(6) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

/* =============================================================================================
  INDEX: USER 2FA TOKEN
============================================================================================= */

CREATE INDEX idx_user_2fa_token_user_id ON user_2fa_token(user_id);

/* =============================================================================================
  INITIAL VALUES: USER 2FA TOKEN
============================================================================================= */

/* =============================================================================================
  END OF TABLE DEFINITIONS
============================================================================================= */


/* =============================================================================================
  TABLE: FAILED LOGIN ATTEMPTS
============================================================================================= */

DROP TABLE IF EXISTS failed_login_attempts;

CREATE TABLE failed_login_attempts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  attempt_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

/* =============================================================================================
  INDEX: FAILED LOGIN ATTEMPTS
============================================================================================= */

CREATE INDEX idx_failed_login_attempts_user_id ON failed_login_attempts(user_id);

/* =============================================================================================
  INITIAL VALUES: FAILED LOGIN ATTEMPTS
============================================================================================= */

/* =============================================================================================
  END OF TABLE DEFINITIONS
============================================================================================= */


/* =============================================================================================
  TABLE: USER TOKEN
============================================================================================= */

DROP TABLE IF EXISTS user_token;

CREATE TABLE user_token (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

/* =============================================================================================
  INDEX: USER TOKENS
============================================================================================= */

CREATE INDEX idx_user_token_user_id ON user_token(user_id);

/* =============================================================================================
  INITIAL VALUES: USER TOKENS
============================================================================================= */

/* =============================================================================================
  END OF TABLE DEFINITIONS
============================================================================================= */


/* =============================================================================================
  TABLE: 
============================================================================================= */

/* =============================================================================================
  INDEX: 
============================================================================================= */

/* =============================================================================================
  INITIAL VALUES: 
============================================================================================= */

/* =============================================================================================
  END OF TABLE DEFINITIONS
============================================================================================= */