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

echo "select osmabbrv_get_streetname_from_tags('"name"=>"Dr. No Street","name:de"=>"Professor-Doktor-No-Straße"',false);"
res=$(psql -X -t -A $DB <<EOF
select osmabbrv_get_streetname_from_tags('"name"=>"Dr. No Street","name:de"=>"Professor-Doktor-No-Straße"',false);
EOF
)
printresult "$res" "‪Prof.-Dr.-No-Str. - Dr. No St.‬"

echo "select osmabbrv_get_name_without_brackets_from_tags('"name"=>"Dr. No Street","name:de"=>"Doktor-No-Straße"');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrv_get_name_without_brackets_from_tags('"name"=>"Dr. No Street","name:de"=>"Doktor-No-Straße"');
EOF
)
printresult "$res" "Doktor-No-Straße"

echo "select osmabbrv_get_streetname_from_tags('"name:de"=>"Doktor-No-Straße"','de',NULL,'Dr. No Street');"
res=$(psql -X -t -A $DB <<EOF
select osmabbrv_get_name_without_brackets_from_tags('"name:de"=>"Doktor-No-Straße"','de',NULL,'Dr. No Street');
EOF
)
printresult "$res" "Doktor-No-Straße"

IFS=,
echo -e "\n---- German abbreviations, data from de_test.csv ----"
while read nameIn nameExpected
do
  stmt="select osmabbrv_get_streetname_from_tags('\"name\"=>\"${nameIn}\"',false);"
  echo ${stmt}
  res=$(psql -X -t -A $DB -c "${stmt}")
  printresult "$res" "${nameExpected}"
done < de_tests.csv

IFS=,
echo -e "\n---- English abbreviations, data from en_test.csv ----"
while read nameIn nameExpected
do
  stmt="select osmabbrv_get_streetname_from_tags('\"name\"=>\"${nameIn}\"',false);"
  echo ${stmt}
  res=$(psql -X -t -A $DB -c "${stmt}")
  printresult "$res" "${nameExpected}"
done < en_tests.csv

echo -e "\n---- French abbreviations, data from fr_test.csv ----"
while read nameIn nameExpected
do
  stmt="select osmabbrv_get_streetname_from_tags('\"name\"=>\"${nameIn}\"',false);"
  echo ${stmt}
  res=$(psql -X -t -A $DB -c "${stmt}")
  printresult "$res" "${nameExpected}"
done < fr_tests.csv

echo -e "\n---- Dutch abbreviations, data from nl_test.csv ----"
while read nameIn nameExpected
do
  stmt="select osmabbrv_get_streetname_from_tags('\"name\"=>\"${nameIn}\"',false);"
  echo ${stmt}
  res=$(psql -X -t -A $DB -c "${stmt}")
  printresult "$res" "${nameExpected}"
done < nl_tests.csv

echo -e "\n$passed tests passed $failed tests failed."

exit $exitval

