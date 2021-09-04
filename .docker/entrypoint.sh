#!/bin/sh

case "$1" in
	""|"sleep"|"loop")
		while :; do sleep 1; done
	;;
	"sh"|"bash"|"shell")
		/usr/bin/env sh
	;;
	"run"|"app")
		mix phx.server
	;;
	*)
		echo -n "unknown entrypoint"
	;;
esac
