#!/bin/bash


if pidof -x $(basename $0) > /dev/null; then
   for p in $(pidof -x $(basename $0)); do
   if [ $p -ne $$ ]; then
   echo "Script $0 is already running: exiting"
    exit
   fi
   done
fi


lowPriority()
{
 echo "$(date) - Start dd with low IO priority." >> /tmp/ionice.log
 ionice -c 2 -n 7 dd if=/dev/random of=/tmp/ioniceLowPri.tmp bs=640M count=2 oflag=dsync > /dev/null 2>&1
 echo "$(date) - Stop dd with low IO priority." >> /tmp/ionice.log
}

hiPriority() {
 echo "$(date) - Start dd with hi IO priority." >> /tmp/ionice.log
 ionice -c 2 -n 0 dd if=/dev/random of=/tmp/ioniceHiPri.tmp bs=640M count=2 oflag=dsync > /dev/null 2>&1
 echo "$(date) - Stop dd with hi IO priority." >> /tmp/ionice.log
}

lowPriority &
hiPriority &

wait

cat /tmp/ionice.log