FROM ubuntu:16.04

ENV ROUTINO_VERSION "3.2"

RUN apt-get update
RUN apt-get install -y mercurial subversion vim nano wget
RUN apt-get install -y gcc make libc6-dev libz-dev libbz2-dev
RUN apt-get install -y libwww-perl liburi-perl libjson-pp-perl
RUN apt-get install -y apache2 libcgi-pm-perl


# Build routino
WORKDIR /tmp
RUN svn checkout http://routino.org/svn/tags/${ROUTINO_VERSION}/ routino
RUN cd routino \
 && make && make install

WORKDIR /tmp/routino
RUN cp -a web /var/www/html/routino
RUN chown -R www-data:www-data /var/www/html/routino

WORKDIR /var/www/html/routino/data
RUN cd /var/www/html/routino/data
COPY create.sh .
RUN sed -i 's/\r//' create.sh
RUN /bin/bash ./create.sh

WORKDIR /var/www/html/routino/www/leaflet
RUN apt-get install -y unzip libapache2-request-perl
RUN cd /var/www/html/routino/www/leaflet
COPY leaflet.sh .
RUN sed -i 's/\r//' leaflet.sh
RUN /bin/bash ./leaflet.sh

WORKDIR /etc/apache2/mods-enabled
RUN sed -i '2 i <Directory /var/www/html/routino>\nAllowOverride Options=MultiViews,ExecCGI FileInfo Limit\n</Directory>' /etc/apache2/sites-enabled/000-default.conf
RUN cd /etc/apache2/mods-enabled
RUN ln -s ../mods-available/cgi.load
#RUN service apache2 reload
RUN apache2ctl restart
 
# Configure Apache2
ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_LOG_DIR      /var/log/apache2
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]