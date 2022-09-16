#!/usr/bin/env bash

if [[ ! -d .git ]]; then
  echo "This is not a git directory!"
  exit 1
fi

NOW=$(date +"%s")
SEC_IN_DAY=86400
DAYS_IN_YEAR=365

TOTAL_AGE_SEC=0
TOTAL_LINES=0

CURRENT_FILE=1
TOTAL_FILES=$(git ls-files | wc -l)

echo "Calculating code age ..."

for FILE in $(git ls-files); do
  PERC=$((100 * CURRENT_FILE / TOTAL_FILES))
  echo -e "\e[1A\e[K$PERC %\t$FILE"

  for LINE in $(git blame "$FILE" --date=unix -c | awk -v FS='\t' '{ print $3 }'); do
    AGE_SEC=$((NOW - LINE))
    TOTAL_AGE_SEC=$((TOTAL_AGE_SEC + AGE_SEC))
    TOTAL_LINES=$((TOTAL_LINES + 1))
  done

  CURRENT_FILE=$((CURRENT_FILE + 1))
done

AVG_AGE_SEC=$((TOTAL_AGE_SEC / TOTAL_LINES))
AVG_AGE_DAYS=$((AVG_AGE_SEC / SEC_IN_DAY))
AVG_AGE_YEARS=$((AVG_AGE_DAYS / DAYS_IN_YEAR))

if [ $AVG_AGE_YEARS == 0 ]; then
  echo "$AVG_AGE_DAYS days"
else
  DAYS_REMAINDER="$((AVG_AGE_DAYS - $((AVG_AGE_YEARS * DAYS_IN_YEAR))))"
  echo "$AVG_AGE_YEARS years, $DAYS_REMAINDER days"
fi
