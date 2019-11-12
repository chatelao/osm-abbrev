#!/bin/bash
#
# This test needs a databse with osmabbrev extension enabled
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

for filename in `ls ../src/*.csv`; do
  IFS=,
  echo -e "\n---- German abbreviations, data from ${filename} ----"
  { 
    read
    while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
    do
      stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
      echo ${stmt}
      res=$(psql -X -t -A $DB -c "${stmt}")
      printresult "$res" "${nameExpected}"
    done
  } < ../src/${filename}
done

# IFS=,
# echo -e "\n---- English abbreviations, data from en_test.csv ----"
# { 
#   read
#   while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
#   do
#     stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
#     echo ${stmt}
#     res=$(psql -X -t -A $DB -c "${stmt}")
#     printresult "$res" "${nameExpected}"
#   done
# } < ../src/latin_en.csv

# echo -e "\n---- French abbreviations, data from fr_test.csv ----"
# { 
#   read
#   while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
#   do
#     stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
#     echo ${stmt}
#     res=$(psql -X -t -A $DB -c "${stmt}")
#     printresult "$res" "${nameExpected}"
#   done
# } < ../src/latin_fr.csv

# echo -e "\n---- Italian abbreviations, data from it_test.csv ----"
# { 
#   read
#   while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
#   do
#     stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
#     echo ${stmt}
#     res=$(psql -X -t -A $DB -c "${stmt}")
#     printresult "$res" "${nameExpected}"
#   done
# } < ../src/latin_it.csv

# echo -e "\n---- Italian abbreviations, data from it_test.csv ----"
# { 
#   read
#   while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
#   do
#     stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
#     echo ${stmt}
#     res=$(psql -X -t -A $DB -c "${stmt}")
#     printresult "$res" "${nameExpected}"
#   done
# } < ../src/latin_es.csv

# echo -e "\n---- Dutch abbreviations, data from nl_test.csv ----"
# { 
#   read
#   while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
#   do
#     stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
#     echo ${stmt}
#     res=$(psql -X -t -A $DB -c "${stmt}")
#     printresult "$res" "${nameExpected}"
#   done
# } < ../src/latin_nl.csv

# echo -e "\n---- Russian abbreviations, data from ru_test.csv ----"
# { 
#   read
#   while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
#   do
#     stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
#     echo ${stmt}
#     res=$(psql -X -t -A $DB -c "${stmt}")
#     printresult "$res" "${nameExpected}"
#   done
# } < ../src/cyrillic_ru.csv

# echo -e "\n---- Belarus abbreviations, data from uk_test.csv ----"
# { 
#   read
#   while read nameIn nameExpected nameRuleLong nameRuleShort nameUrlSample
#   do
#     stmt="select osmabbrv_street_abbrev_all('${nameIn}');"
#     echo ${stmt}
#     res=$(psql -X -t -A $DB -c "${stmt}")
#     printresult "$res" "${nameExpected}"
#   done
# } < ../src/cyrillic_uk.csv

exit $exitval
