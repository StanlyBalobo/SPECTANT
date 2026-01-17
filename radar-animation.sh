#!/bin/bash
# radar-animation.sh
while true; do
  clear
  echo "📡 PENTEST RADAR - SCANNING..."
  for i in {1..12}; do
    echo -n "  " 
    for j in {1..12}; do
      if [ $((i+j)) -eq 13 ]; then echo -n "█"; else echo -n " "; fi
    done
    echo ""
  done
  sleep 0.2
done
