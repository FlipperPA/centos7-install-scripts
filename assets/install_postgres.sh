#!/bin/bash
#
# This script will install and enable PostgreSQL 9.5 for CentOS 7 locally
# for development. Must be sudo'd.
#

echo "Adding the PostgreSQL 9.5 CentOS repository..."
rpm -Uvh http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm
echo "Installing PostgreSQL..."
yum -y --quiet install postgresql95-server postgresql95
/usr/pgsql-9.5/bin/postgresql95-setup initdb
systemctl start postgresql-9.5
systemctl enable postgresql-9.5
# firewall-cmd --permanent --add-service postgresql > /dev/null 2>&1
# systemctl restart firewalld > /dev/null 2>&1
echo "PostgreSQL installation complete."

while [[ $# > 1 ]]
do
    key="$1"

    case $key in
	-u|--username)
	USERNAME="$2"
        shift # past argument
	;;
    esac
    shift # past argument or value
done

# A username for initial set up has been passed.
if [ ${#USERNAME} -eq 0 ]
then
    # This hasn't been implemented yet.
    # echo 'This script requires a username to be passed for the initial PostgreSQL root user.'
    # echo 'Please pass it with "./install-postgres.sh -u username".'
else
    echo USERNAME  = "${USERNAME}"
    #CREATE USER tom WITH PASSWORD 'myPassword';
    #CREATE DATABASE jerry;
    #GRANT ALL PRIVILEGES ON DATABASE jerry to tom;
    #\q
    sudo -u postgres createuser -sd ${USERNAME}
    sudo -u postgres createdb ${USERNAME}
fi

echo ${#USERNAME}
