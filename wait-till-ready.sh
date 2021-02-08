!/bin/bash

attempt_counter=0
max_attempts=14
sleep_time=10

if [ $# -lt 1 ]
then
  echo "missing arguments. Expect URL as an argument"
  echo "example: ./wait-until-ready.sh http://someurl"
  exit 1
fi

URL=$1

wait_for_page() {
    echo "wait_for_page: $1"
    until [ $(curl -s -o /dev/null -w '%{http_code}' $1) -eq 200 ]; do
        if [ ${attempt_counter} -eq ${max_attempts} ];then
        echo "Max attempts reached"
        exit 1
        fi

        printf '.'
        attempt_counter=$(($attempt_counter+1))
        sleep $sleep_time
    done
    echo " Ready."
}

wait_for_page "$URL"
