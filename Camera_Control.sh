#!/bin/sh

sudo su;

## set pin 35 as input for switch, and pin 37 as input for ignition
echo "35" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio35/direction

echo "37" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio37/direction

portcheck=0
cam_ip="192.168.1.201"
stop_tracking="/cgi-bin/rainBrush.cgi?action=stopMove[&channel=1]"
start_tracking="/cgi-bin/rainBrush.cgi?action=moveContinuously&interval=1[&channel=1]"
while [ $portcheck -lt 1 ]; do
    check80=($(nc -zv $cam_ip' 80' | grep -o "open"))
    if [ -n "$check80" ]; then
        check554=($(nc -zv $cam_ip' 554'))
        if [ -n "$check554" ]; then
            let portcheck=1
        fi
    else
        sleep 5
    fi
done

## main loop
infinite=0
switch_state=($(cat /sys/class/gpio/gpio35/value))
prev_sw_state=$switch_state
while [ $infinite -lt 1 ]; do
    $switch_state=($(cat /sys/class/gpio/gpio35/value))
    if [ switch_state -ne prev_sw_state ]; then
        if [ prev_sw_state -eq 1 ]; then
            curl -user admin:admin $cam_ip$start_tracking
        else
            curl -user admin:admin $cam_ip$stop_tracking
        fi
        let $prev_sw_state=$switch_state
    fi

    ignition_state=($(cat /sys/class/gpio/gpio37/value))
    if [ ignition_state -ne 1 ]; then
        poweroff
    fi
done