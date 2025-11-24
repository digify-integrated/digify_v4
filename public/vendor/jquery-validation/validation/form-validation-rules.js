// Form validation rules
$.validator.addMethod('password_strength', function(value) {
    // Password must be at least 8 characters with at least one lowercase, one uppercase, one digit, and one special character (dot or underscore)
    return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&._])[A-Za-z\d@$!%*?&._]{8,}$/.test(value);
}, 'Password must be at least 8 characters long. Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character');

// Rule for legal age
$.validator.addMethod('employee_age', function(value, element, min) {
    var today = new Date();
    var birthDate = new Date(value);
    var age = today.getFullYear() - birthDate.getFullYear();
  
    if (age > min+1) { return true; }
  
    var m = today.getMonth() - birthDate.getMonth();
  
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) { age--; }
  
    return age >= min;
}, 'The employee must be at least 18 years old and above');

// Rule for contact emergency contact
$.validator.addMethod('contactEmergencyContactRequired', function(value, element) {
    var emailIsEmpty = $("#emergency_contact_email").val() === "";
    var mobileIsEmpty = $("#emergency_contact_mobile").val() === "";
    var telephoneIsEmpty = $("#emergency_contact_telephone").val() === "";

    return !(emailIsEmpty && mobileIsEmpty && telephoneIsEmpty);
}, 'Please enter either email, mobile, or telephone');

$.validator.addMethod("employeeLicenseDateGreaterOrEqual", function (value, element, param) {
    var startMonth = parseInt($('#license_start_month').val(), 10);
    var startYear = parseInt($('#license_start_year').val(), 10);
    var endMonth = parseInt($('#license_end_month').val(), 10);
    var endYear = parseInt($('#license_end_year').val(), 10);

    if (isNaN(endYear) || isNaN(endMonth)) {
        return true;
    }

    if (endYear > startYear) {
        return true;
    } else if (endYear === startYear && endMonth >= startMonth) {
        return true;
    }

    return false;
}, "End date cannot be earlier than the start date");
