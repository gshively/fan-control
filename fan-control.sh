#!/bin/bash

on_exit() {
	echo "Resetting back to iDrac Fan Control"
	ipmitool raw 0x30 0x30 0x01 0x01
	exit 0
}
trap on_exit SIGINT SIGTERM EXIT

LAST_FAN_POWER=0
ipmitool raw 0x30 0x30 0x01 0x00
while :; do
	sensor=`ipmitool sdr get Temp`
	min=`grep "Nominal Reading" <<< "$sensor" | cut -d: -f 2`; min=${min%%.*}
	max=`grep "Normal Maximum" <<< "$sensor" | cut -d: -f 2`; max=${max%%.*}
	current=`grep "Sensor Reading" <<< "$sensor" | cut -d: -f 2 | cut -d " " -f 2`
	base=$(( current - min ))
	total=$(( max - min ))
	percent=$(( base * 100 / total ))
	fan_power=$(( percent / 10 * 10 - 5))
	echo "fan power before chunking $fan_power"
	if [[ $fan_power -lt 15 ]]; then
		echo "Fan power of $fan_power < 15; setting min of 15"
		fan_power=15
	elif [[ $fan_power -gt 100 ]]; then
		echo "Fan power of $fan_power > 100; setting max of 100"
		fan_power=100
	fi

	fan_speed=`ipmitool sensor get "Sys Fan1" | grep "Sensor Reading" | cut -d: -f 2`
	echo "Current Fan Speed: $fan_speed"

	if [[ $fan_power -ne $LAST_FAN_POWER ]]; then
		echo "Setting Fan Power of $fan_power for current temp of $current"
		pcthex=$(printf '0x%02x' $fan_power)
		ipmitool raw 0x30 0x30 0x02 0xff $pcthex
		LAST_FAN_POWER=$fan_power
	else
		echo "Same Fan power setting as last run at $fan_power for $current; not changing"
	fi


	sleep 90
done
