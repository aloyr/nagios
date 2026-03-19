FROM rockylinux:9
ARG NAGIOS_VERSION="4.5.9"
ENV NAGIOS_VERSION=$NAGIOS_VERSION
ARG NAGIOS_PLUGINS_VERSION="2.4.12"
ENV NAGIOS_PLUGINS_VERSION=$NAGIOS_PLUGINS_VERSION
ARG NAGIOS_NRPE_VERSION="4.1.3"
ENV NAGIOS_NRPE_VERSION=$NAGIOS_NRPE_VERSION
ADD https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-${NAGIOS_VERSION}/nagios-${NAGIOS_VERSION}.tar.gz /usr/local/src/
ADD https://nagios-plugins.org/download/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz /usr/local/src/
ADD https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-${NAGIOS_NRPE_VERSION}/nrpe-${NAGIOS_NRPE_VERSION}.tar.gz /usr/local/src/
RUN dnf -y install dnf-plugins-core;
RUN dnf -y config-manager --set-enabled crb extras plus;
RUN dnf -y install https://rpms.remirepo.net/enterprise/remi-release-9.rpm;
RUN dnf -y module enable php:remi-8.3;
RUN dnf -y install epel-release;
RUN dnf -y --enablerepo devel \
      install \
        bind-utils \
        compat-openssl11 \
        fping \
        gzip \
        gd-devel \
        glibc-devel \
        gnutls-devel \
        httpd \
        httpd-devel \
        kernel-headers \
        krb5-devel \
        libdb-devel \
        libdb-utils \
        libgdata \
        libgdata-devel \
        libpq \
        libpq-devel \
        libtool-ltdl-devel \
        mod_auth_openidc \
        mod_ldap \
        mod_security \
        mod_ssl \
        mysql-common \
        mysql-devel \
        net-snmp \
        net-snmp-devel \
        net-snmp-perl \
        net-snmp-utils \
        openldap-clients \
        openldap-devel \
        openssl-devel \
        php83-php \
        php83-php-soap \
        php83-php-process \
        php83-php-opcache \
        php83-php-odbc \
        php83-php-mysqlnd \
        php83-php-mbstring \
        php83-php-intl \
        php83-php-gd \
        php83-php-pecl-xdebug3 \
        php83-php-pecl-redis5 \
        php83-php-pecl-msgpack \
        php83-php-pecl-imagick \
        php83-php-pecl-igbinary \
        php83-php-pecl-json-post \
        python3-pip \
        perl \
        perl-devel \
        perl-LWP-Protocol-https \
        perl-libwww-perl \
        perl-Text-Glob \
        perl-Time-ParseDate \
        postfix \
        procps-ng \
        qstat \
        rpcbind \
        samba-client \
        samba-devel \
        sudo \
        sudo-devel \
        s-nail \
        traceroute \
        which;
RUN dnf -y group install "Development Tools";
RUN cd /usr/bin; \
    ln -s python3 python; \
    pip install supervisor; \
    /usr/libexec/httpd-ssl-gencerts; \
    cd /usr/local/src; \
    tar -zvxf nagios-${NAGIOS_VERSION}.tar.gz; \
    ls -l /usr/local/src; \
    cd nagios-${NAGIOS_VERSION}; \
    useradd -r nagios; \
    ./configure; \
    make all -j8; \
    make install test; \
    make install; \
    make install-init; \
    make install-daemoninit; \
    make install-groups-users; \
    make install-commandmode; \
    make install-config; \
    make install-webconf; \
    make install-classicui; \
    make install-exfoliation;
RUN cd /usr/local/src; \
    tar -zvxf nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz; \
    cd nagios-plugins-${NAGIOS_PLUGINS_VERSION}; \
    ./configure; \
    make -j8; \
    make install; \
    make install-root;
RUN cd /usr/local/src; \
    tar -zvxf nrpe-${NAGIOS_NRPE_VERSION}.tar.gz; \
    cd nrpe-${NAGIOS_NRPE_VERSION}; \
    ./configure; \
    make all; \
    make install; \
    make install-groups-users; \
    make install-plugin; \
    make install-daemon; \
    make install-config;
ADD htpasswd.users /usr/local/nagios/etc/htpasswd.users
ADD supervisord.conf /supervisord.conf
CMD ["supervisord","-c","/supervisord.conf"]
