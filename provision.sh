#
# Install dependencies
#
DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y devscripts equivs jq npm
apt-get install -y postgresql-10-postgis-2.4
apt-get install -y 

npm install -g csvtojson
npm install -g mustache
cd /vagrant/src
mustache test.json street_abbrv.mustache.sql

#
# Create the database (gis)
#
sudo -u postgres createuser --superuser --no-createdb --no-createrole maposmatic
sudo -u postgres createuser -g maposmatic root
sudo -u postgres createuser -g maposmatic vagrant

sudo mk-build-deps -i debian/control
# mk-build-deps -t 'apt-get -o Debug::pkgProblemResolver=yes --install-recommends -qqy' -i -r debian/control
pg_lsclusters
pg_config --sharedir
sudo pg_config --sharedir
sudo -u postgres pg_config --sharedir

sudo -u postgres createdb --encoding=UTF8 --locale=en_US.UTF-8 --template=template0 gis
sudo -u postgres psql --dbname=gis --command="CREATE EXTENSION postgis"
sudo -u postgres psql --dbname=gis --command="CREATE EXTENSION hstore"

#
# Build the L10N extensions
#
cd /vagrant

mkdir gen
make -np all
make all
cat gen/*.json
cat gen/*.sql
sudo make install

#
# Deploy the L10N extensions to the database (gis)
#
sudo -u postgres psql --dbname=gis --command="CREATE EXTENSION osmabbrv"

#
# Test the L10N extensions in the database (gis)
#
cd /vagrant/tests
./runtests_pgsql.sh gis
