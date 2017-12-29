#!/bin/python3
# author: Andrea de Palo - andrea.de.palo@oracle.com

from sys import argv

import re

script, log_file = argv

server_list=[]

include_user=False

with open(log_file, "r", encoding="utf-8") as f:
    listener_fh=open(log_file, "r")
    for listener_line in listener_fh.readlines():
        if re.search("HOST=", listener_line):
            client=listener_line.split("HOST=")[1].split(")(")[0]
            if include_user == True:
                if re.search("USER=", listener_line):
                    c_user=listener_line.split("USER=")[1].split("))")[0]
                    client=client+" - "+c_user
            if client not in server_list:
                server_list.append(client)

for client in server_list:
    print(client)
