#!/usr/bin/perl

# author: Andrea de Palo
# clean Oracle RDBMS log files

# /u01/app/11.2.0.3/grid/log/diag/tnslsnr/LXDAM001/listener_scan3/alert
#   *xml log files
# /u01/app/11.2.0.3/grid/log/diag/tnslsnr/LXDAM001/listener_scan3/trace/listener_scan3.log
# /u01/app/grid/crsdata/ebm4dbadm01/core/core.*
# /u01/app/grid/diag/tnslsnr/ebm4dbadm01/listener_ebm2_listener1/alert/*xml
# /u01/app/grid/diag/tnslsnr/ebm4dbadm01/listener/alert
# $ORACLE_BASE/admin/$ORACLE_SID/adump

# TODO
# add automatic discovery of OHs
# - truncate log files
#   + listener
#   + alert
# - clear xml files
# - add dry run option

use strict;
use warnings;

use File::Path;

# my $host = hostname();
# print "$host\n";

# my $filename = '/etc/oratab';
# open(my $fh, $filename) or die "Could not open file '$filename' $!";

# while (my $row = <$fh>) {
#     chomp $row;
#     if (!($row =~ "^#.*")){
#         if ($row =~ '^\S+'){
#             my @product_path=split(':', $row);
#             print "$product_path[0]\n";
#             print "$product_path[1]\n";
#         }
#     }
# }

while (glob('/u01/app/oracle/product/agent/agent_inst/sysman/emd/core.*')) {
    print "deleting: $_\n";
    unlink($_) or die "Cannot unlink '$_' : $!";
}

while (glob('/u01/app/oracle/product/agent/agent_inst/sysman/log/heapDump_*.hprof')) {
    print "deleting: $_\n";
    unlink($_) or die "Cannot unlink '$_' : $!";
}

while (glob('/u01/app/oracle/product/agent/agent_inst/diag/ofm/emagent/emagent/incident/*')){
    print "deleting: $_\n";
    rmtree($_) or die "Cannot rmtree '$_' : $!";
}
