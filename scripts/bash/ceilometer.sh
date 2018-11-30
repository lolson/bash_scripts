#!/bin/bash
SERVICE_HOST=192.168.2.200
TOKEN=b5490add76fc41aea9bcebe59a4fb45a
TS=`date +%Y-%m-%d`
TS_QUERY=\'"{\"q\": [{\"field\": \"timestamp\", \"op\": \"ge\", \"value\": \"$TS\"}]}"\'

get_auth() {
   curl -s -X POST http://$SERVICE_HOST:5000/v2.0/tokens \
            -H "Content-Type: application/json" \
            -d '{"auth": {"tenantName": "'"admin"'", "passwordCredentials":
            {"username": "'"admin"'", "password": "'"openstack1234"'"}}}' \
            | python -m json.tool
}

get_meters() {
   curl -H "X-Auth-Token: $TOKEN" \
       "http://$SERVICE_HOST:8777/v2/meters" \
       | python -m json.tool
}

echo_ts() {
        echo "-d" $TS_QUERY
}

get_meters() {
   curl -H "X-Auth-Token: $TOKEN" -d $TS_QUERY \
       "http://$SERVICE_HOST:8777/v2/meters/cpu" \
       | python -m json.tool
}

get_meters
#echo_ts
