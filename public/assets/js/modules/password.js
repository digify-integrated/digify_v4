export const passwordAddOn = () => {
  $('.password-addon').each(function () {
    const $addon        = $(this);
    const $inputField   = $addon.siblings('input');
    const $eyeIcon      = $addon.find('i');

    if ($inputField.attr('type') === 'password') {
      $eyeIcon.removeClass('ki-eye-slash').addClass('ki-eye');
    } else {
      $eyeIcon.removeClass('ki-eye').addClass('ki-eye-slash');
    }

    $addon.attr({
      tabindex: 0,
      role: 'button',
      'aria-label': 'Toggle password visibility'
    });

    const togglePassword = () => {
      const isPassword = $inputField.attr('type') === 'password';
      $inputField.attr('type', isPassword ? 'text' : 'password');
      $eyeIcon.toggleClass('ki-eye-slash ki-eye');
    };

    $addon.off('click').on('click', togglePassword);

    $addon.off('keydown').on('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        togglePassword();
      }
    });
  });
};
