#!/usr/bin/python

# 1 - chiedere schema/tabella/partizione
# 2 - chiedere compressione
# 3 - chiedere parallelismo
# 4 - generare filename del dump / log
#       20140515-TICKET-SCHEMA.00-AMBIENTE-depa.dmp
# 5 
# 6 SOLO IMPDP
# 7 - table_exists_action

import sys
import time

current_date = time.strftime('%Y%m%d')

datapump_string = ""

operation = raw_input("export/import: ")
if (operation == "export"):
    operation_command = "expdp userid=\"'/ as sysdba'\" "
elif (operation == "import"):
    operation_command = "impdp userid=\"'/ as sysdba'\" "
else:
    print("operation not recognized")
    sys.exit(1)

datapump_string = operation_command

object_input = raw_input("schema or tables?: ")

if (object_input == "schema"):
    object_type = "SCHEMAS"
elif (object_input == "tables"):
    object_type = "TABLES"
else:
    print("object input not recognized")
    sys.exit(1)

datapump_string = datapump_string + object_type + "="

object_string = raw_input("object string (schema name, tables names: ")
datapump_string = datapump_string + object_string

if (operation == "export"):
    datapump_string = datapump_string + " COMPRESSION=ALL ESTIMATE=statistics"

# datapump directory
directory_input = raw_input("dump directory? ")
datapump_string = datapump_string + " DIRECTORY=" + directory_input

# parallel
# TODO chiedere valore di parallel
parallel_option = raw_input("parallel [y/N]: ")
if (parallel_option == 'y'):
    datapump_string = datapump_string + " PARALLEL=4"

# ambiente
environment = raw_input("environment? (COL, PRD)")
# TODO controllare stringa

# dumpfile
if (parallel_option == 'y'):
    datapump_string = datapump_string + " DUMPFILE=" + current_date +"-"+object_string+"-"+environment+".%U-depa.dmp"
else:
    datapump_string = datapump_string + " DUMPFILE=" + current_date +"-"+object_string+"-"+environment+"-depa.dmp"

# logfile
datapump_string = datapump_string + " LOGFILE=" + current_date +"-"+object_string+"-"+environment+"-depa.log"

print(datapump_string)
sys.exit(0)
