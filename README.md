## Pterodactyl Panel container
This container is built to run the pterodactyl server management panel.

Built from the stock [alpine linux](https://hub.docker.com/_/alpine/) using the build in edge repositories to get the latest PHP 7 on top of nginx. Supervisord starts both nginx and php-fpm.

Quay.io Build Status  
![status badge](https://quay.io/repository/parkervcp/pterodactyl-panel/status)


# Large UPDATE and changes

#### changes
* Changed base mariadb container (smaller)  
* Moved to caddyserver and tini  
* Added Automatic SSL support (Can be disabled)  
    Auto SSL certs are based on the admin_email and panel_url variables in the docker-compose file  
    Adding auto SSL support doesn't work for everyone so I have added the ability to disable ssl. You just need to set ssl to false in the docker-compose file.



## Running the container
Pull the container  
```docker pull quay.io/parkervcp/pterodactyl-panel```

You can use the docker-compose.yml to run the containers if you want. This will start a mariadb container and link it to the panel. This connection is internal only.  
You run the containers by running
```docker-compose -d```

More info on docker-compose can be found [here](https://docs.docker.com/compose/)

###When you first start the container you need to wait at least 1 minute for it to complete the final setup including the database configuration/seeding, email setup, and user generation.

#####If you don't use docker-compose
The container requires a database to run as well. I recommend the [mariadb conatiner](https://hub.docker.com/_/mariadb/) or [alpine mariadb container](https://github.com/bianjp/docker-mariadb-alpine). I start it with a command like this. Modify to your needs.  
```docker run -t -e MYSQL_ROOT_PASSWORD=apassword -e MYSQL_DATABASE=pterodb -e MYSQL_USER=ptero -e MYSQL_PASSWORD=pterodbpass --name pterodb -d mariadb:10```
The container also requires a ton of env flags and that is why the docker-compose is the recommended way to run the container

```docker run -it -p 80:80 -p 443:443 -v /srv/pterodactyl/.env:/var/www/html/.env --link pterodb -e db_host=pterodb -e db_port=3306 -e db_name=pterodb -e db_user=ptero -e db_pass=pterodbpass -e panel_url= -e timezone="America/New_York" -e email_driver=mail -e panel_email=foo@bar.org --name pterosite quay.io/parkervcp/pterodactyl-panel:latest```
The full list of supported env flags are:  
#####DB settings
db_host="hostname"  
db_port="port"  
db_name="db name"  
db_user="username"  
db_pass="db pass"  
panel_url="Panel Url"  
timezone="Panel Timezone in php time"  

#####Email settings
email_driver="email driver"  
panel_email="email address for the panel"  
email_user="email username"  
email_pass="email password"  
email_domain="email domain"  
email_port="email port"  

Only the driver and email address are required for the "mail" driver.  
driver, email, and username(api key) are used for "mandrill" and "postmark".  
driver, email, username(api key), and domain are required for "mailgun".
All settings are required for "smtp"

#####Admin setup
admin_email="admin email"  
admin_pass="admin password"  
admin_stat=1 (should stay 1 to set user as admin)

## Support & Documentation
Support for using Pterodactyl can be found on our [wiki](https://github.com/Pterodactyl/Panel/wiki) or on our [Discord chat](https://discord.gg/0gYt8oU8QOkDhKLS).

### Credits
A huge thanks to [pterodactyl](https://github.com/Pterodactyl/Panel) .
