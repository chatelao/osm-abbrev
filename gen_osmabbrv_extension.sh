#!/bin/bash

# generate psql extension "osmabbrv"
# from plpgsql scripts
# version must be given as parameter
if [ $# -ne 2 ]; then
  echo "usage: genextension.sh <data_target_dir> <version>" >&2
  exit 1
fi

# check if commands we need are available
for cmd in curl sed basename; do
  if ! command -v $cmd >/dev/null; then
    echo "ERROR: command >>$cmd<< not found, please install!" >&2
    exit 1
  fi
done

# # download country_osm_grid.sql from nominatim if not available
# if ! [ -f "country_osm_grid.sql" ]; then
#   rm -f country_osm_grid.sql
#   echo -n "Trying to download country_grid.sql.gz from nominatim.org... "
#   curl -s http://www.nominatim.org/data/country_grid.sql.gz |gzip -d >country_osm_grid.sql

#   if ! [ -s country_osm_grid.sql ]; then
#     rm -f country_osm_grid.sql
#     echo "failed."
#     exit 1
#   else
#     echo "done."
#   fi
# fi

SCRIPTS=plpgsql/*

(
echo "-- complain if script is sourced in psql, rather than via CREATE EXTENSION"
echo '\echo Use "CREATE EXTENSION osmabbrv" to load this file. \quit'
echo
) >>osmabbrv--$2.sql

for f in $SCRIPTS; do
  bn=$(basename $f)
  echo "" >>osmabbrv--$2.sql
  echo "-- pl/pgSQL code from file $bn -----------------------------------------------------------------" >>osmabbrv--$2.sql
  cat $f >>osmabbrv--$2.sql
done

echo "
-- function osmabbrv_version  -----------------------------------------------------------------
CREATE or REPLACE FUNCTION osmabbrv_version() RETURNS TEXT AS \$\$
 BEGIN
  RETURN '$2';
 END;
\$\$ LANGUAGE 'plpgsql' IMMUTABLE;
" >>osmabbrv--$2.sql
