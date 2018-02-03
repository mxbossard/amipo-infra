#!/usr/bin/env python
# Adapted from Mark Mandel's implementation
# https://github.com/ansible/ansible/blob/stable-2.1/contrib/inventory/vagrant.py
# All hosts are grouped under vagrant and test

import argparse
import json
import subprocess
import sys


def parse_args():
    parser = argparse.ArgumentParser(description="LXC inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    return parser.parse_args()


def list_running_hosts():
    cmd = "lxc-ls -1"
    hosts = []
    status = subprocess.check_output(cmd.split()).rstrip()
    for host in status.split('\n'):
        hosts.append(host)

    return hosts


def get_host_details(host):
    cmd = "lxc-info -n {} -iH".format(host)
    ip = subprocess.check_output(cmd.split()).rstrip()
    return {'ansible_host': ip}


def main():
    args = parse_args()
    if args.list:
        hosts = list_running_hosts()
        json.dump({'lxcContainers': hosts}, sys.stdout)
    else:
        details = get_host_details(args.host)
        json.dump(details, sys.stdout)

if __name__ == '__main__':
    main()
