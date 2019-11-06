#!/bin/bash
#
# This test needs a databse with osml10n extension enabled
#
#

if [ $# -ne 1 ]; then
  echo "usage: $0 <dbname>"
  exit 1
fi

cd $(dirname "$0")

# check if commands we need are available
for cmd in psql uconv; do
  if ! command -v $cmd >/dev/null; then
    echo -e "[\033[1;31mERROR\033[0;0m]: command >>$cmd<< not found, please install!"
    exit 1
  fi
done

DB=$1

exitval=0

passed=0
failed=0

# $1 result
# $2 expected
function printresult() {
  if [ "$1" = "$2" ]; then
    echo -n -e "[\033[0;32mOK\033[0;0m]     "
    ((passed++))
  else
    echo -n -e "[\033[1;31mFAILED\033[0;0m] "
    ((failed++))
    exitval=1
  fi
  echo -e "(expected >$2<, got >$1<)"
}

echo "select osmabbrev_get_streetname_from_tags('"name"=>"Dr. No Street","name:de"=>"Professor-Doktor-No-Straße"',false);"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_streetname_from_tags('"name"=>"Dr. No Street","name:de"=>"Professor-Doktor-No-Straße"',false);
EOF
)
printresult "$res" "‪Prof.-Dr.-No-Str. - Dr. No St.‬"

echo "select osmabbrev_get_name_without_brackets_from_tags('"name"=>"Dr. No Street","name:de"=>"Doktor-No-Straße"');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_name_without_brackets_from_tags('"name"=>"Dr. No Street","name:de"=>"Doktor-No-Straße"');
EOF
)
printresult "$res" "Doktor-No-Straße"

echo "select osmabbrev_get_name_without_brackets_from_tags('"name:de"=>"Doktor-No-Straße"','de',NULL,'Dr. No Street');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_name_without_brackets_from_tags('"name:de"=>"Doktor-No-Straße"','de',NULL,'Dr. No Street');
EOF
)
printresult "$res" "Doktor-No-Straße"

IFS=,
echo -e "\n---- German abbreviations, data from de_test.csv ----"
while read nameIn nameExpected
do
  stmt="select osmabbrev_get_streetname_from_tags('\"name\"=>\"${nameIn}\"',false);"
  echo ${stmt}
  res=$(psql -X -t -A $DB -c "${stmt}")
  printresult "$res" "${nameExpected}"
done < ../defs/de_tests.csv

IFS=,
echo -e "\n---- English abbreviations, data from en_test.csv ----"
while read nameIn nameExpected
do
  stmt="select osmabbrev_get_streetname_from_tags('\"name\"=>\"${nameIn}\"',false);"
  echo ${stmt}
  res=$(psql -X -t -A $DB -c "${stmt}")
  printresult "$res" "${nameExpected}"
done < ../defs/en_tests.csv

echo -e "\n---- French abbreviations, data from fr_test.csv ----"
while read nameIn nameExpected
do
  stmt="select osmabbrev_get_streetname_from_tags('\"name\"=>\"${nameIn}\"',false);"
  echo ${stmt}
  res=$(psql -X -t -A $DB -c "${stmt}")
  printresult "$res" "${nameExpected}"
done < ../defs/fr_tests.csv

echo

echo "select osmabbrev_get_streetname_from_tags('"name"=>"улица Воздвиженка","name:en"=>"Vozdvizhenka Street"',true,true,' ','de');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_streetname_from_tags('"name"=>"улица Воздвиженка","name:en"=>"Vozdvizhenka Street"',true,true,' ','de');
EOF
)
printresult "$res" "‪ул. Воздвиженка (Vozdvizhenka St.)‬"

#  Russian language
echo "select osmabbrev_get_streetname_from_tags('"name"=>"улица Воздвиженка"',true,true,' ','de');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_streetname_from_tags('"name"=>"улица Воздвиженка"',true,true,' ','de');
EOF
)
printresult "$res" "‪ул. Воздвиженка (ul. Vozdviženka)‬"

# Belarusian language (AFAIK)
echo "select osmabbrev_get_streetname_from_tags('"name"=>"вулиця Молока"',true,false,' - ','de');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_streetname_from_tags('"name"=>"вулиця Молока"',true,false,' - ','de');
EOF
)
printresult "$res" "‪вул. Молока - vul. Moloka‬"

# upstream carto style database layout
echo "select osmabbrev_get_streetname_from_tags('',true,false,' - ','de',NULL,'вулиця Молока');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_streetname_from_tags('',true,false,' - ','de',NULL,'вулиця Молока');
EOF
)
printresult "$res" "‪вул. Молока - vul. Moloka‬"

echo "select osmabbrev_get_placename_from_tags('"name"=>"주촌  Juchon", "name:ko"=>"주촌","name:ko-Latn"=>"Juchon"',true,false,'|');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_placename_from_tags('"name"=>"주촌  Juchon", "name:ko"=>"주촌","name:ko_rm"=>"Juchon"',true,false,'|');
EOF
)
printresult "$res" "‪주촌|Juchon‬"

echo "select osmabbrev_get_placename_from_tags('"name"=>"주촌", "name:ko"=>"주촌","name:ko-Latn"=>"Juchon"',false,false,'|');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_placename_from_tags('"name"=>"주촌", "name:ko"=>"주촌","name:ko_rm"=>"Juchon"',false,false,'|');
EOF
)
printresult "$res" "‪Juchon|주촌‬"

echo "select osmabbrev_get_streetname_from_tags('"name"=>"ဘုရားကိုင်လမ်း Pha Yar Kai Road", "highway"=>"secondary", "name:en"=>"Pha Yar Kai Road", "name:my"=>"ဘုရားကိုင်လမ်း"',true,false,'|');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_streetname_from_tags('"name"=>"ဘုရားကိုင်လမ်း Pha Yar Kai Road", "highway"=>"secondary", "name:en"=>"Pha Yar Kai Road", "name:my"=>"ဘုရားကိုင်လမ်း"',true,false,'|');
EOF
)
printresult "$res" "‪ဘုရားကိုင်လမ်း|Pha Yar Kai Rd.‬"

echo "select osmabbrev_get_streetname_from_tags('"name"=>"ဘုရားကိုင်လမ်း", "highway"=>"secondary", "name:en"=>"Pha Yar Kai Road", "name:my"=>"ဘုရားကိုင်လမ်း"',true,false,'|');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_streetname_from_tags('"name"=>"ဘုရားကိုင်လမ်း", "highway"=>"secondary", "name:en"=>"Pha Yar Kai Road", "name:my"=>"ဘုရားကိုင်လမ်း"',true,false,'|');
EOF
)
printresult "$res" "‪ဘုရားကိုင်လမ်း|Pha Yar Kai Rd.‬"

echo "select osmabbrev_get_country_name('"ISO3166-1:alpha2"=>"IN","name:de"=>"Indien","name:hi"=>"भारत","name:en"=>"India"','|');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrev_get_country_name('"ISO3166-1:alpha2"=>"IN","name:de"=>"Indien","name:hi"=>"भारत","name:en"=>"India"','|');
EOF
)
printresult "$res" "Indien|भारत|India"

echo -e "\n$passed tests passed $failed tests failed."

exit $exitval
