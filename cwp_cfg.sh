#!/bin/bash
    set -ex

    # Enter Prisma Cloud URL and Token
    var_url="https://console-master-demo.mweibeler.demo.twistlock.com"
    var_token=""
    # var_vapp_img="nginx:latest"

    # Stop learning for vulnerable app container
    PROFILE_ID=$(curl -k -X GET -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' "${var_url}/api/v1/profiles/container" | jq -r ' .[] | select(.image == "fefefe8888/l4s-demo-app:1.0") | ._id ')
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"state": "manualActive"}' "${var_url}/api/v1/profiles/container/$PROFILE_ID/learn"

    # Add Collections - Working
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app1","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app1"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var_url}/api/v1/collections"
    curl -k -X POST -H "authorization: Bearer ${var_token}" -H 'Content-Type: application/json' -d '{"name":"Log4Shell demo - vul-app2","images":["fefefe8888/l4s-demo-app:1.0"],"containers":["vul-app2"],"hosts":["*"],"namespaces":["*"],"labels":["*"],"accountIDs":["*"],"clusters":["*"]}' "${var_url}/api/v1/collections"