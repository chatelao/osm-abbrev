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
# echo "-- enable libkakasi based kanji transcription function -----------------------------------------------------------------" 
# echo
# echo "CREATE OR REPLACE FUNCTION osmabbrv_kanji_transcript(text)RETURNS text AS"
# echo "'\$libdir/osmabbrv_kanjitranscript', 'osmabbrv_kanji_transcript'"
# echo "LANGUAGE C STRICT;"
# echo
# echo "-- enable ICU any-latin transliteration function -----------------------------------------------------------------"
# echo
# echo "CREATE OR REPLACE FUNCTION osmabbrv_translit(text)RETURNS text AS"
# echo "'\$libdir/osmabbrv_translit', 'osmabbrv_translit'"
# echo "LANGUAGE C STRICT;"
) >>osmabbrv--$2.sql

for f in $SCRIPTS; do
  bn=$(basename $f)
  echo "" >>osmabbrv--$2.sql
  echo "-- pl/pgSQL code from file $bn -----------------------------------------------------------------" >>osmabbrv--$2.sql
  cat $f >>osmabbrv--$2.sql
done
# NO-COUNTRY - echo "-- country_osm_grid.sql -----------------------------------------------------------------" >>osmabbrv--$2.sql
# NO-COUNTRY - sed '/^COPY.*$/,/^\\\.$/d;//d' country_osm_grid.sql |grep -v -e '^--' |grep -v 'CREATE INDEX' | cat -s >>osmabbrv--$2.sql
# NO-COUNTRY - echo -e "COPY country_osm_grid (country_code, area, geometry) FROM '$1/osmabbrv_country_osm_grid.data';\n"  >>osmabbrv--$2.sql
# NO-COUNTRY - grep 'CREATE INDEX' country_osm_grid.sql  >>osmabbrv--$2.sql
# NO-COUNTRY - echo "GRANT SELECT on country_osm_grid to public;" >>osmabbrv--$2.sql

# NO-COUNTRY - echo -e "\n-- country_languages table from http://wiki.openstreetmap.org/wiki/Nominatim/Country_Codes -----------------------------" >>osmabbrv--$2.sql
# NO-COUNTRY - echo "CREATE TABLE country_languages(iso text, langs text[]);" >>osmabbrv--$2.sql
# NO-COUNTRY - echo "COPY country_languages (iso, langs) FROM '$1/country_languages.data';"  >>osmabbrv--$2.sql
# NO-COUNTRY - echo -e "GRANT SELECT on country_languages to public;\n" >>osmabbrv--$2.sql

echo "
-- function osmabbrv_version  -----------------------------------------------------------------
CREATE or REPLACE FUNCTION osmabbrv_version() RETURNS TEXT AS \$\$
 BEGIN
  RETURN '$2';
 END;
\$\$ LANGUAGE 'plpgsql' IMMUTABLE;
" >>osmabbrv--$2.sql

# NO-COUNTRY - sed '/^COPY.*$/,/^\\\.$/!d;//d'  country_osm_grid.sql >osmabbrv_country_osm_grid.data
