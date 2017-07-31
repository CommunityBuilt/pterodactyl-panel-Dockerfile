#!/bin/ash
set -e

if [ "$1" = "/sbin/tini" ]; then

    echo "container initializing"
    echo "setting up ssl settings"
    
    if [ "$ssl" == "false" ]; then
        echo "disabling ssl support" 
        sed -i "s,https://,http://,g" /etc/caddy/caddy.conf
        sed -i "s,<domain>,$panel_url,g" /etc/caddy/caddy.conf
        sed -i "s,<email>,off,g" /etc/caddy/caddy.conf
    else
        echo "configuring ssl support"
        sed -i "s,<domain>,$panel_url,g" /etc/caddy/caddy.conf
        sed -i "s,<email>,$admin_email,g" /etc/caddy/caddy.conf
    fi

    echo "continuing"

    if [ ! -e var/.env ] || [ ! -s var/.env ]; then #Didn't find the .env file
        echo "      Getting ready to start. Waiting 15 seconds for mariadb to start if you are using docker compose"
        sleep 15
        echo "      env not found. Copying from example"
        if [ ! -e var/.env ]; then
            touch var/.env
        else
            echo "If you see this there was a major problem..."
        fi
        ln -fs var/.env .env
        echo "      Generating application key"
        php artisan key:generate --force
        echo "  Setting up db and email settings"
        php artisan pterodactyl:env --driver=$driver --session-driver=$session_driver --queue-driver=$queue_driver --dbhost=$db_host --dbport=$db_port --dbname=$db_name --dbuser=$db_user --dbpass=$db_pass --url=$panel_url --timezone=$timezone
        case "$email_driver" in
            mail)
            echo "      PHP Mail was chosen"
            php artisan pterodactyl:mail --from-name=$from_name --driver=$email_driver --email=$panel_email
            ;;
            mandrill)
            php artisan pterodactyl:mail --from-name=$from_name --driver=$email_driver --email=$panel_email --username=$email_user
            echo "      Mandrill was chosen"
            ;;
            postmark)
            php artisan pterodactyl:mail --from-name=$from_name --driver=$email_driver --email=$panel_email --username=$email_user
            echo "      Postmark was chosen"
            ;;
            mailgun)
            php artisan pterodactyl:mail --from-name=$from_name --driver=$email_driver --email=$panel_email --username=$email_user --host=$email_domain
            echo "      Mailgun was chosen"
            ;;
            smtp)
            php artisan pterodactyl:mail --from-name=$from_name --driver=$email_driver --email=$panel_email --username=$email_user --password=$email_pass --host=$email_domain --port=$email_port
            echo "      smtp was chosen"
            ;;
            *)
            echo "      There was an error and you need to run the container again with the email information"
         esac
            echo "      Migrating Database"
            php artisan migrate --force
            echo "      Seeding Database"
            php artisan db:seed --force
            echo "      Setting up user"
            php artisan pterodactyl:user --email=$admin_email --password=$admin_pass  --firstname=$admin_firstname  --lastname=$admin_lastname  --username=$admin_username --admin=$admin_stat

    else # Found an env file and testing for panel version
        echo "      Found env file found. continuing start"
        ln -fs var/.env .env
    fi
fi

exec "$@"
