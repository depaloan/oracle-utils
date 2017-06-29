#!/bin/bash

# TODO: portare queste variabili in un file esterno
export DCLI_GROUP='/home/oracle/ebm2n.dcli'
export TARGET_HOME_PARENT='/u01/app/oracle/product/12.1.0.2'
export DBHOME_ARCHIVE='dbhome_12.1.0.2.170418.tar.gz'
export DBHOME_ARCHIVE_PATH='/zfssa/scripts/PATCHES'
export DBHOME_NAME='dbhome_170418'
export INVENTORY_HOME_NAME='OraDB12r1Home'
export TARGET_ORACLE_BASE='/u01/app/oracle'
export TARGET_ORACLE_HOME="${TARGET_HOME_PARENT}/${DBHOME_NAME}"
export CLONE_CLUSTER_NODES=$(paste -d, -s $DCLI_GROUP)
export CLONE_COMMAND_SCRIPT='/tmp/oracle-dbhome-clone.command.sh'
export CLONE_ROOT_COMMAND_SCRIPT='/tmp/oracle-dbhome-clone.command-root.sh'


# test connectivity
# expected outout: hostname for each server defined in $DCLI_GROUP
dcli -l oracle -g $DCLI_GROUP hostname

# create parent directory for target dbhome
# expected output (one of the two)
#   - directory already exists
#   - or directory created
dcli -l oracle -g $DCLI_GROUP mkdir $TARGET_HOME_PARENT

# verify before extracting
dcli -l oracle -g $DCLI_GROUP "ls -lh ${DBHOME_ARCHIVE_PATH}/${DBHOME_ARCHIVE}"

# extract OH archive from ZFS
dcli -l oracle -g $DCLI_GROUP "tar xzvf ${DBHOME_ARCHIVE_PATH}/${DBHOME_ARCHIVE} -C ${TARGET_HOME_PARENT}"
# alternative: if ZFS or NFS share is not available, copy via scp
# "scp -c arcfour ebm1ndbadm03:/tmp/dbhome_170418.tar.gz /u01/app/oracle/product/12.1.0.2/"

# cleanup data from other/old installation
dcli -l oracle -g $DCLI_GROUP "rm -fr ${TARGET_HOME_PARENT}/${DBHOME_NAME}/rdbms/audit/* ${TARGET_HOME_PARENT}/${DBHOME_NAME}/log/*"

# check free space / dbhome size
dcli -l oracle -g $DCLI_GROUP "du -hs ${TARGET_HOME_PARENT}/${DBHOME_NAME}"
dcli -l oracle -g $DCLI_GROUP "df -h ${TARGET_HOME_PARENT}/${DBHOME_NAME}"


# create clone script
cat <<EOF > $CLONE_COMMAND_SCRIPT
unset ORACLE_SID
export TARGET_ORACLE_HOME="${TARGET_HOME_PARENT}/${DBHOME_NAME}"
export TARGET_ORACLE_BASE="${TARGET_ORACLE_BASE}"
export NODE_NAME=\`hostname -s\`
START_DIRECTORY=\$PWD

#echo DEBUG
#echo \$NODE_NAME
#echo \$TARGET_ORACLE_HOME
#echo \$TARGET_ORACLE_BASE

echo "Execution of the following command will begin in 5 seconds"
echo perl clone.pl '-O "CLUSTER_NODES={$CLONE_CLUSTER_NODES}"' -O "LOCAL_NODE=\$NODE_NAME" ORACLE_BASE=${TARGET_ORACLE_BASE}  ORACLE_HOME=${TARGET_ORACLE_HOME}  ORACLE_HOME_NAME=${INVENTORY_HOME_NAME} '-O -noConfig'
echo "CTRL-C to ABORT now!"
sleep 5
cd "$TARGET_ORACLE_HOME/clone/bin"
perl clone.pl '-O "CLUSTER_NODES={$CLONE_CLUSTER_NODES}"' -O "LOCAL_NODE=\$NODE_NAME" ORACLE_BASE=${TARGET_ORACLE_BASE}  ORACLE_HOME=${TARGET_ORACLE_HOME}  ORACLE_HOME_NAME=${INVENTORY_HOME_NAME} '-O -noConfig'
cd $START_DIRECTORY
EOF
chmod +x $CLONE_COMMAND_SCRIPT

dcli -l oracle -g $DCLI_GROUP -f $CLONE_COMMAND_SCRIPT -d /tmp/
dcli -l oracle -g $DCLI_GROUP md5sum $CLONE_COMMAND_SCRIPT


# TODO
# testare esecuzione di $CLONE_COMMAND_SCRIPT attraverso dcli
# 2017.06.29: testato solo manualmente su ogni nodo
dcli -l oracle -g $DCLI_GROUP $CLONE_COMMAND_SCRIPT


# finalize home clone process
cat <<EOF > $CLONE_ROOT_COMMAND_SCRIPT
/usr/local/bin/dcli -l root -g $DCLI_GROUP ${TARGET_HOME_PARENT}/${DBHOME_NAME}/root.sh
EOF
chmod +x $CLONE_ROOT_COMMAND_SCRIPT
sudo $CLONE_ROOT_COMMAND_SCRIPT

# TODO
# implementare un controllo per questi log
#   ebm2ndbadm01: Check /u01/app/oracle/product/12.1.0.2/dbhome_170418/install/root_ebm2ndbadm01.gbm.lan_2017-06-29_13-33-46.log for the output of root script
#   ebm2ndbadm02: Check /u01/app/oracle/product/12.1.0.2/dbhome_170418/install/root_ebm2ndbadm02.gbm.lan_2017-06-29_13-33-46.log for the output of root script
#   ebm2ndbadm03: Check /u01/app/oracle/product/12.1.0.2/dbhome_170418/install/root_ebm2ndbadm03.gbm.lan_2017-06-29_13-33-46.log for the output of root script
#   ebm2ndbadm04: Check /u01/app/oracle/product/12.1.0.2/dbhome_170418/install/root_ebm2ndbadm04.gbm.lan_2017-06-29_13-33-46.log for the output of root script
# grep ORA- /path/to/file


# final check
dcli -l oracle -g $DCLI_GROUP ${TARGET_ORACLE_HOME}/OPatch/opatch lspatches
