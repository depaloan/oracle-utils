#!/bin/bash

# author: Andrea de Palo - andrea.de.palo@oracle.com

# display ASM global information
# display ASM information for each database

asmcmd lsdg *C1
echo -e "\n"

# list of DBs to be excluded from the output, if present
execution_directory=`dirname $0`

if [[ -f $execution_directory/asm-du.exception ]]; then
    db_exception=`cat $execution_directory/asm-du.exception`
fi

echo "DATABASE_NAME,DATAC1_MB_USAGE,RECOC1_MB_USAGE"
crsctl stat res -t | grep '\.db$' | while read output_line; do
    dbname=`echo $output_line | awk -F"." '{ print $2 }'`
    uc_dbname=${dbname^^}
    #echo $uc_dbname
    if [[ $db_exception != *"$uc_dbname"* ]]; then
        datac1_usage=`asmcmd du --suppressheader DATAC1/$uc_dbname|awk -F" " '{print $1}'`
        recoc1_usage=`asmcmd du --suppressheader RECOC1/$uc_dbname|awk -F" " '{print $1}'`
        #asmcmd du RECOC1/$uc_dbname
        echo "$uc_dbname,$datac1_usage,$recoc1_usage"
    fi
done
