#!/bin/bash
if
test -d /proc/sys/net/ipv6/conf/proton0; then
    status="on"
else
    status="off"
fi
echo "{\"text\": \"$status\", \"percentage\": \"0\", \"class\": \"vpn\"}"