echo 'This git install should probably already be done, since you checked it out of a repo...'
yum -y install git

echo 'Install the greatest OS and text editor, emacs...'
yum -y install emacs-nox

echo 'Enabling Extra Packages for Enterprise Linux (EPEL) repository...'
yum -y -q install deltarpm
yum -y -q install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm > /dev/null 2>&1
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 > /dev/null 2>&1

# Apache
echo 'Installing Apache...'
yum -y -q install httpd mod_ssl httpd-devel > /dev/null 2>&1
systemctl start httpd > /dev/null 2>&1
systemctl enable httpd > /dev/null 2>&1

# Check to see if Python 3.5.1 is installed
echo "Checking for Python 3.5.1 installation..."
/usr/local/bin/python3.5 --version | grep '3.5.1' &> /dev/null 2>&1
if [ $? == 0 ];
then
    echo "Python 3.5.1 already installed..."
else
    # Python 3.5.1 not installed, let's install it.
    echo "Python 3.5.1 is not installed, installing Python 3 pre-requisites..."
    yum -y -q groupinstall development > /dev/null 2>&1

    echo 'Installing extra packages for Python... (Step 4/12)'
    yum -y -q install zlib-devel openssl-devel sqlite-devel bzip2-devel python-devel openssl-devel libffi-devel openssl-perl libjpeg-turbo-devel zlib-devel giflib ncurses-devel gdbm-devel xz-devel tkinter readline-devel tk tk-devel unixODBC-devel freetds-devel memcached postgresql-devel dos2unix

    echo 'Installing Python 3.5.1...'
    wget -q 'https://www.python.org/ftp/python/3.5.1/Python-3.5.1.tgz'
    tar -xzf 'Python-3.5.1.tgz'
    cd ./Python-3.5.1
    CXX=g++ ./configure --enable-shared --quiet
    make > /dev/null 2>&1

    echo 'Moving to alternate location to keep system Python version intact...'
    make altinstall > /dev/null 2>&1
    cd ..
    rm Python-3.5.1.tgz
    rm -rf ./Python-3.5.1
    ln -fs /usr/local/bin/python3.5 /usr/bin/python3.5
    echo "/usr/local/lib/python3.5" > /etc/ld.so.conf.d/python35.conf
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/python35.conf
    ldconfig
fi

# virtualenvwrapper
echo "Checking for virtualenvwrapper 4.7.0 installation..."
if [ -f /usr/lib/python2.7/site-packages/virtualenvwrapper-4.7.0.dist-info/METADATA ];
then
    echo "virtualenvwrapper 4.7.0 already installed..."
else
    echo "Installing virtualenvwrapper 4.7.0..."
    python assets/get-pip.py > /dev/null 2>&1
    pip install --upgrade ndg-httpsclient > /dev/null 2>&1
    pip install virtualenvwrapper==4.7.0 --quiet > /dev/null 2>&1
    pip install Pygments==2.1 --quiet > /dev/null 2>&1
    # Hack for wheel bdist until new version of virtualenv is release
    rm -f /usr/lib/python2.7/site-packages/virtualenv_support/wheel-0.24.0*
    cp assets/wheel-0.26.0-py2.py3-none-any.whl /usr/lib/python2.7/site-packages/virtualenv_support
    chmod 664 /usr/lib/python2.7/site-packages/virtualenv_support/*
fi

# MOD_WSGI
echo "Checking for mod_wsgi 4.4.21 installation..."
if [ -f /usr/lib64/httpd/modules/mod_wsgi_4.4.21.txt ]
then
    echo "mod_wsgi 4.4.21 already installed..."
else
    echo "Compiling and installing mod_wsgi 4.4.21..."
    wget -q "https://github.com/GrahamDumpleton/mod_wsgi/archive/4.4.21.tar.gz"
    tar -xzf '4.4.21.tar.gz'
    cd ./mod_wsgi-4.4.21
    ./configure --with-python=/usr/local/bin/python3.5 --quiet
    make > /dev/null 2>&1
    make install > /dev/null 2>&1
    touch /usr/lib64/httpd/modules/mod_wsgi_4.4.21.txt
    cd ..
    rm '4.4.21.tar.gz'
    rm -rf ./mod_wsgi-4.4.21
fi

# MEMCACHED
echo "Installing memcached... (Step 10/12)"
cp assets/memcached /etc/sysconfig/
dos2unix -q /etc/sysconfig/memcached
systemctl enable memcached > /dev/null 2>&1
systemctl start memcached > /dev/null 2>&1

# virtualenvwrapper - enum34 causes conflicts.
echo "Configuring virtualenv and virtualenvwrapper settings... (Step 11/12)"
pip uninstall -y enum34 --quiet > /dev/null 2>&1

cp assets/bashrc.txt /etc/skel/.bashrc
