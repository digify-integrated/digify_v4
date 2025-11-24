export const setHereClassForMenu = (menuContainerSelector, menuSelector) => {
  const currentUrl      = window.location.href.split('?')[0];
  const menuContainer   = document.querySelector(menuContainerSelector);

  if (!menuContainer) return;

  const firstLevelMenuItems = menuContainer.querySelectorAll(menuSelector);

  firstLevelMenuItems.forEach((menuItem) => {
    let hasChildMatch   = false;
    const childLinks    = menuItem.querySelectorAll('.menu-sub .menu-link');

    if (childLinks.length > 0) {
      childLinks.forEach((childLink) => {
        if (childLink.href && childLink.href.split('?')[0] === currentUrl) {
          hasChildMatch = true;
          childLink.classList.add('active');
        }
      });

      if (hasChildMatch) {
        menuItem.classList.add('here', 'show');
      }
    } else {
      const menuLink        = menuItem.querySelector('.menu-link');
      const menuLinkAnchor  = menuLink?.closest('a'); // could be null

      if (menuLinkAnchor) {
        if (menuLinkAnchor.href.split('?')[0] === currentUrl) {
          menuItem.classList.add('here');
        }
      } else if (menuLink) {
        console.warn(
          'setHereClassForMenu: .menu-link found without a parent <a> element:',
          menuLink
        );
      }
    }
  });
};
