<?php

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Database;
use App\Core\Helpers;

class AuthController extends Controller
{
    protected $db;
    protected $helpers;

    public function __construct()
    {
        $this->db = Database::getInstance();
        $this->helpers = new Helpers();
        session_start();
    }

    /**
     * Show registration form
     */
    public function register()
    {
        return $this->view('auth/register');
    }

    /**
     * Handle registration form submission
     */
    public function registerPost()
    {
        $email = $_POST['email'] ?? '';
        $mobile = $_POST['mobile'] ?? '';
        $password = $_POST['password'] ?? '';
        $profile_name = $_POST['profile_name'] ?? '';

        if (!$email || !$mobile || !$password || !$profile_name) {
            return $this->view('auth/register', ['error' => 'All fields are required']);
        }

        // Check if email or mobile already exists
        $existing = $this->db->query(
            "SELECT * FROM users WHERE email = :email OR mobile = :mobile",
            ['email' => $email, 'mobile' => $mobile]
        );

        if ($existing->rowCount() > 0) {
            return $this->view('auth/register', ['error' => 'Email or Mobile already registered']);
        }

        // Hash password
        $password_hash = password_hash($password, PASSWORD_DEFAULT);

        // Create user with is_active = 'No'
        $this->db->query(
            "INSERT INTO users (tenant_id, email, mobile, password, profile_name, is_active) 
            VALUES (:tenant_id, :email, :mobile, :password, :profile_name, 'No')",
            [
                'tenant_id' => 1, // For now, single tenant, can expand later
                'email' => $email,
                'mobile' => $mobile,
                'password' => $password_hash,
                'profile_name' => $profile_name
            ]
        );

        $user_id = $this->db->lastInsertId();

        // Generate email verification token
        $token = bin2hex(random_bytes(16));
        $expires_at = date('Y-m-d H:i:s', strtotime('+24 hours'));
        $this->db->query(
            "INSERT INTO email_verification_token (user_id, token, expires_at) VALUES (:user_id, :token, :expires_at)",
            ['user_id' => $user_id, 'token' => $token, 'expires_at' => $expires_at]
        );

        // Send verification email
        $verification_link = BASE_URL . "/auth/verifyEmail?token=$token";
        $subject = "Verify Your Email";
        $body = "Hi $profile_name,<br>Please verify your email by clicking the link: <a href='$verification_link'>$verification_link</a>";
        $this->helpers->sendEmail($email, $subject, $body);

        return $this->view('auth/register', ['success' => 'Registration successful! Please verify your email.']);
    }

    /**
     * Email verification
     */
    public function verifyEmail()
    {
        $token = $_GET['token'] ?? '';

        if (!$token) {
            die('Invalid token');
        }

        $row = $this->db->query(
            "SELECT * FROM email_verification_token WHERE token = :token",
            ['token' => $token]
        )->fetch();

        if (!$row) {
            die('Token not found or expired');
        }

        if (strtotime($row['expires_at']) < time()) {
            die('Token expired');
        }

        // Activate user
        $this->db->query(
            "UPDATE users SET is_active = 'Yes' WHERE id = :user_id",
            ['user_id' => $row['user_id']]
        );

        // Delete token
        $this->db->query("DELETE FROM email_verification_token WHERE id = :id", ['id' => $row['id']]);

        echo "Email verified successfully! You can now login.";
    }

    /**
     * Show login form
     */
    public function login()
    {
        return $this->view('auth/login');
    }

    /**
     * Handle login post
     */
    public function loginPost()
    {
        $email = $_POST['email'] ?? '';
        $password = $_POST['password'] ?? '';
        $remember = $_POST['remember'] ?? false;

        if (!$email || !$password) {
            return $this->view('auth/login', ['error' => 'Email and Password are required']);
        }

        $user = $this->db->query("SELECT * FROM users WHERE email = :email", ['email' => $email])->fetch();

        if (!$user || $user['is_active'] !== 'Yes') {
            return $this->view('auth/login', ['error' => 'Invalid credentials or email not verified']);
        }

        // Check brute force
        $failedAttempts = $this->db->query(
            "SELECT COUNT(*) as fail_count FROM failed_login_attempts WHERE user_id = :user_id AND attempt_time > :time",
            [
                'user_id' => $user['id'],
                'time' => date('Y-m-d H:i:s', strtotime('-15 minutes'))
            ]
        )->fetchColumn();

        if ($failedAttempts >= 5) {
            return $this->view('auth/login', ['error' => 'Too many failed attempts. Try again in 15 minutes.']);
        }

        if (!password_verify($password, $user['password'])) {
            // Record failed attempt
            $this->db->query("INSERT INTO failed_login_attempts (user_id) VALUES (:user_id)", ['user_id' => $user['id']]);
            return $this->view('auth/login', ['error' => 'Invalid credentials']);
        }

        // Clear failed login attempts on successful login
        $this->db->query("DELETE FROM failed_login_attempts WHERE user_id = :user_id", ['user_id' => $user['id']]);

        // Check if 2FA enabled
        if ($user['two_factor_enabled'] === 'Yes') {
            // Generate OTP
            $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
            $expires_at = date('Y-m-d H:i:s', strtotime('+5 minutes'));

            $this->db->query(
                "INSERT INTO user_2fa_token (user_id, token, expires_at) VALUES (:user_id, :token, :expires_at)",
                ['user_id' => $user['id'], 'token' => $otp, 'expires_at' => $expires_at]
            );

            // Send OTP via email (or SMS)
            $subject = "Your OTP Code";
            $body = "Hi {$user['profile_name']}, your OTP code is: $otp. It is valid for 5 minutes.";
            $this->helpers->sendEmail($user['email'], $subject, $body);

            $_SESSION['2fa_user_id'] = $user['id'];
            return $this->view('auth/twofactor');
        }

        // Login success
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['tenant_id'] = $user['tenant_id'];
        $_SESSION['2fa_verified'] = true;

        if ($remember) {
            $token = bin2hex(random_bytes(32));
            $expires_at = date('Y-m-d H:i:s', strtotime('+24 hours'));

            $this->db->query(
                "INSERT INTO user_token (user_id, token, expires_at) VALUES (:user_id, :token, :expires_at)",
                ['user_id' => $user['id'], 'token' => $token, 'expires_at' => $expires_at]
            );

            setcookie('remember_me', $token, time() + 86400, "/", "", false, true);
        }

        header('Location: /app');
        exit;
    }

    /**
     * Show 2FA form
     */
    public function twoFactor()
    {
        return $this->view('auth/twofactor');
    }

    /**
     * Handle 2FA form
     */
    public function twoFactorPost()
    {
        $user_id = $_SESSION['2fa_user_id'] ?? null;
        $otp = $_POST['otp'] ?? '';

        if (!$user_id || !$otp) {
            return $this->view('auth/twofactor', ['error' => 'Invalid request']);
        }

        $row = $this->db->query(
            "SELECT * FROM user_2fa_token WHERE user_id = :user_id ORDER BY created_at DESC LIMIT 1",
            ['user_id' => $user_id]
        )->fetch();

        if (!$row || $row['token'] !== $otp || strtotime($row['expires_at']) < time()) {
            return $this->view('auth/twofactor', ['error' => 'Invalid or expired OTP']);
        }

        // Remove used OTP
        $this->db->query("DELETE FROM user_2fa_token WHERE id = :id", ['id' => $row['id']]);

        // Set session
        $user = $this->db->query("SELECT * FROM users WHERE id = :id", ['id' => $user_id])->fetch();
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['tenant_id'] = $user['tenant_id'];
        $_SESSION['2fa_verified'] = true;

        unset($_SESSION['2fa_user_id']);

        header('Location: /app');
        exit;
    }

    /**
     * Logout
     */
    public function logout()
    {
        if (isset($_COOKIE['remember_me'])) {
            $this->db->query("DELETE FROM user_token WHERE token = :token", ['token' => $_COOKIE['remember_me']]);
            setcookie('remember_me', '', time() - 3600, "/", "", false, true);
        }

        session_destroy();
        header('Location: /auth/login');
        exit;
    }
}
