#/bin/bash
ps aux | grep pmon | awk -F" " '{print $11}' | grep -v grep | awk -F"_" '{print "   "$3}' | sort
