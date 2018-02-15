#!/usr/bin/env python
# Adapted from Mark Mandel's implementation
# https://github.com/ansible/ansible/blob/stable-2.1/contrib/inventory/vagrant.py
# All hosts are grouped under vagrant and test

import argparse
import json
import subprocess
import sys
import re

def parse_args():
    parser = argparse.ArgumentParser(description="LXC inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    return parser.parse_args()

#def addLxcSuffix(name):
#    return name + ".lxc"
#
#def removeLxcSuffix(name):
#    return re.match(r'(.*?)(\.lxc)?$', name).group(1)

def list_lxc_groups(availableLxcHosts):
    file = None
    try:
        file = open("/home/lxc/.lxc_ansible_groups", "r")
        groupsMap = {}
        for line in file.readlines():
            row = line.split(':')
            #host = addLxcSuffix(row[0]).rstrip()
            host = row[0].rstrip()
            groups = row[1].split(',')
            if host in availableLxcHosts:
                for group in groups:
                    group = group.rstrip()
                    if group:
                        hostList = groupsMap.get(group, [])
                        hostList.append(host)
                        groupsMap[group] = hostList
    finally:
        if file:
            file.close()

    return groupsMap


def list_running_hosts():
    cmd = "lxc-ls -1"
    hosts = []
    status = subprocess.check_output(cmd.split()).rstrip()
    for host in status.split('\n'):
        #hosts.append(addLxcSuffix(host))
        hosts.append(host)

    return hosts


def get_host_details(host):
    #cmd = "lxc-info -n {} -iH".format(removeLxcSuffix(host))
    cmd = "lxc-info -n {} -iH".format(host)
    ip = subprocess.check_output(cmd.split()).rstrip()
    return {'ansible_host': ip}


def main():
    args = parse_args()
    if args.list:
        hosts = list_running_hosts()
        groupsMap = list_lxc_groups(hosts)
        #groupsMap["lxc"] = hosts
        json.dump(groupsMap, sys.stdout)
    else:
        details = get_host_details(args.host)
        json.dump(details, sys.stdout)

    print ''

if __name__ == '__main__':
    main()

