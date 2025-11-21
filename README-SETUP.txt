1) Place this project at:
   C:\xampp\htdocs\digify_v4

2) Set Apache DocumentRoot to:
   C:\xampp\htdocs\digify_v4\public
   (Or configure a VirtualHost pointing to that folder)

3) In project root run:
   composer install

4) Copy .env.example -> .env and adjust settings.

5) Ensure storage/logs and storage/uploads exist and are writable by Apache.

6) Open http://localhost/digify_v4/ (or your configured host) and you should see the home page.

Optional:
 - For quick local testing without changing Apache, you may run:
   composer start
   then open http://localhost:8000
