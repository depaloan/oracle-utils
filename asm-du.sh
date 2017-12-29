#!/bin/bash

# author: Andrea de Palo - andrea.de.palo@oracle.com

# display ASM global information
# display ASM information for each database

asmcmd lsdg *C1
echo -e "\n"

echo "DATABASE_NAME,DATAC1_MB_USAGE,RECOC1_MB_USAGE"
crsctl stat res -t | grep '\.db$' | while read output_line; do
    dbname=`echo $output_line | awk -F"." '{ print $2 }'`
    uc_dbname=${dbname^^}
    #echo $uc_dbname
    datac1_usage=`asmcmd du --suppressheader DATAC1/$uc_dbname|awk -F" " '{print $1}'`
    recoc1_usage=`asmcmd du --suppressheader RECOC1/$uc_dbname|awk -F" " '{print $1}'`
    #asmcmd du RECOC1/$uc_dbname
    echo "$uc_dbname,$datac1_usage,$recoc1_usage"
done
