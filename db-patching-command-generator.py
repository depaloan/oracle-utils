#!/usr/bin/python3

# author: andrea.de.palo@oracle.com
# scope: generate the required commands to move a DB to a new OH in order to
#           apply BP/PSU. Instances are bounced in transactional mode, with
#           services relocated to the other node

# TODO:
# - provide a "conf" flag to specify a different configuration file
# - provide an "exadata" flag to differentiate the catbundle command
# - automatically generate the list of services to be relocated after the bounce
# - add to the configuration file the possibility to have different instance
#       numbers (e.g. 3,4)

with open('db-patching-command-generator.txt') as database_list:
    for line in database_list:
        line=line.rstrip()
        database_name,target_oh,release,database_bc,database_dr=line.split(';')

        if (release not in ['11g', '12c']):
            print("ERROR. Release {0} not recognized for database {1}".format(release,database_name))
        else:
            # only when Data Guard is configured
            # dgmgrl commands to disable DG replicas
            if (database_bc != 'NONE'):
                print("# {0}: disable Data Guard replica".format(database_name))
                print("source ~/.{0}.profile".format(database_name))
                print("/zfssa/scripts/ODG/{0}/dgmgrl_{0}.sh < /zfssa/scripts/ODG/{0}/{0}-db.patching-prepare.dgmgrl".format(database_name))
                print ("")

            if (database_dr != 'NONE'):
                print("# {0}: DR".format(database_dr))
                print("source ~/.{0}.profile".format(database_dr))
                if (release == '11g'):
                    print("srvctl status database -d {0} -v".format(database_dr))
                    print("srvctl stop database -d {0}".format(database_dr))
                    print("srvctl modify database -d {0} -o {1}".format(database_dr,target_oh))
                    print("srvctl start database -d {0}".format(database_dr))
                    print("srvctl status database -d {0} -v".format(database_dr))
                elif (release == '12c'):
                    print("srvctl status database -db {0} -v".format(database_dr))
                    print("srvctl stop database -db {0}".format(database_dr))
                    print("srvctl modify database -db {0} -oraclehome {1}".format(database_dr,target_oh))
                    print("srvctl start database -db {0}".format(database_dr))
                    print("srvctl status database -db {0} -v".format(database_dr))
                print("# INFO. Remember to modify the ORACLE_HOME variable in ~/.{0}.profile".format(database_dr))
                print ("")

            if (database_bc != 'NONE'):
                print("# {0}: BC".format(database_bc))
                print("source ~/.{0}.profile".format(database_bc))
                if (release == '11g'):
                    print("srvctl status database -d {0} -v".format(database_bc))
                    print("srvctl stop database -d {0}".format(database_bc))
                    print("srvctl modify database -d {0} -o {1}".format(database_bc,target_oh))
                    print("srvctl start database -d {0}".format(database_bc))
                    print("srvctl status database -d {0} -v".format(database_bc))
                elif (release == '12c'):
                    print("srvctl status database -db {0} -v".format(database_bc))
                    print("srvctl stop database -db {0}".format(database_bc))
                    print("srvctl modify database -db {0} -oraclehome {1}".format(database_bc,target_oh))
                    print("srvctl start database -db {0}".format(database_bc))
                    print("srvctl status database -db {0} -v".format(database_bc))
                print("# INFO. Remember to modify the ORACLE_HOME variable in ~/.{0}.profile".format(database_bc))
                print ("")

            print("# {0}: PR".format(database_name))
            print("source ~/.{0}.profile".format(database_name))
            print("srvctl status database -d {0} -v".format(database_name))

            if (release == '11g'):
                print("srvctl stop instance -d {0} -i {0}1 -o \"transactional local\" -f".format(database_name))
            elif (release == '12c'):
                print("srvctl stop instance -db {0} -i {0}1 -stopoption \"transactional local\" -failover".format(database_name))

            if (release == '11g'):
                print("srvctl modify database -d {0} -o {1}".format(database_name,target_oh))
            elif (release == '12c'):
                print("srvctl modify database -db {0} -oraclehome {1}".format(database_name,target_oh))

            print("srvctl start instance -d {0} -i {0}1".format(database_name))

            if (release == '11g'):
                print("srvctl stop instance -d {0} -i {0}2 -o \"transactional local\" -f".format(database_name))
            elif (release == '12c'):
                print("srvctl stop instance -db {0} -i {0}2 -stopoption \"transactional local\" -failover".format(database_name))

            print("srvctl start instance -d {0} -i {0}2".format(database_name))
            print("srvctl status database -d {0}  -v".format(database_name))

            print("# execute the following command if a service need to be relocated on the second node")
            if (release == '11g'):
                print("srvctl relocate service -d {0} -s SERVICE_NAME -i {0}1 -t {0}2 ".format(database_name))
            elif (release == '12c'):
                print("srvctl relocate service -db {0} -service SERVICE_NAME -oldinst {0}1 -newinst {0}2 -eval".format(database_name))
                print("srvctl relocate service -db {0} -service SERVICE_NAME -oldinst {0}1 -newinst {0}2".format(database_name))

            print("# INFO. Remember to modify the ORACLE_HOME variable in ~/.{0}.profile".format(database_name))
            print("export ORACLE_HOME='{0}'".format(target_oh))
            print("export PATH='{0}/OPatch':$PATH".format(target_oh))
            print("unset SQLPATH ORACLE_PATH")

            if (release == '11g'):
                print("# execute the following command in SQL*Plus: @?/rdbms/admin/catbundle.sql exa apply")
            elif (release == '12c'):
                print("datapatch -verbose")
            print ("")

            # only when Data Guard is configured
            # dgmgrl commands to enable DG replicas
            if (database_bc != 'NONE'):
                print("# {0}: enable Data Guard replica".format(database_name))
                print("source ~/.{0}.profile".format(database_name))
                print("/zfssa/scripts/ODG/{0}/dgmgrl_{0}.sh < /zfssa/scripts/ODG/{0}/{0}-db.patching-restore.dgmgrl".format(database_name))
                print ("")

            print ("")
            print ("")
            print ("")
            print ("")
            print ("")
