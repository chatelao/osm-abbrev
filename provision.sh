#
# Install dependencies
#
DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y devscripts equivs
apt-get install -y postgresql-11
apt-get install -y postgis
apt-get install -y postgresql-11-postgis-2.5
apt-get install -y postgresql-11-postgis-2.5-scripts

apt-get install -y postgresql-plpython3-11
apt-get install -y python3-pip

sudo pip3 install tltk


#
# Create the database (gis)
#
sudo -u postgres createuser --superuser --no-createdb --no-createrole maposmatic
sudo -u postgres createuser -g maposmatic root
sudo -u postgres createuser -g maposmatic vagrant

sudo -u postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 gis
sudo -u postgres psql --dbname=gis --command="CREATE EXTENSION postgis"
sudo -u postgres psql --dbname=gis --command="CREATE EXTENSION hstore"

#
# Build the L10N extensions
#
cd /vagrant
mk-build-deps -t 'apt-get -o Debug::pkgProblemResolver=yes --install-recommends -qqy' -i -r debian/control
make install

#
# Deploy the L10N extensions to the database (gis)
#
sudo -u postgres psql --dbname=gis --command="CREATE EXTENSION osmabbrv CASCADE"

#
# Test the L10N extensions in the database (gis)
#
cd tests
./runtests.sh gis