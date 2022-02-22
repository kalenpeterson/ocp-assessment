#!/bin/bash
name="test_alert_1"
url='http://localhost:9093/api/v1/alerts'
echo "firing up alert $name"
startsAt=`date --iso-8601=seconds`
curl -XPOST $url -d "[{
        \"status\": \"firing\",
        \"labels\": {
                \"alertname\": \"$name\",
                \"service\": \"test_service\",
                \"severity\":\"warning\",
                \"instance\": \"$name.example.com\"
        },
        \"annotations\": {
                \"summary\": \"This is a test.\"
        },
        \"generatorURL\": \"http://prometheus.example.com\"
}]"
echo ""
echo "press enter to resolve alert"
read
endsAt=`date --iso-8601=seconds`
echo "sending resolve"
curl -XPOST $url -d "[{
        \"status\": \"resolved\",
        \"labels\": {
                \"alertname\": \"$name\",
                \"service\": \"test_service\",
                \"severity\":\"warning\",
                \"instance\": \"$name.example.com\"
        },
        \"annotations\": {
                \"summary\": \"This is a test.\"
        },
        \"generatorURL\": \"http://prometheus.example.com\"
}]"
echo ""