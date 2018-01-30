#!/usr/bin/env python
# Adapted from Mark Mandel's implementation
# https://github.com/ansible/ansible/blob/stable-2.1/contrib/inventory/vagrant.py
# All hosts are grouped under vagrant and test

import argparse
import json
import paramiko
import subprocess
import sys


def parse_args():
    parser = argparse.ArgumentParser(description="Vagrant inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    return parser.parse_args()


def list_running_hosts():
    cmd = "vagrant status --machine-readable"
    hosts = []
    try:
        status = subprocess.check_output(cmd.split()).rstrip()
        for line in status.split('\n'):
            (_, host, key, value) = line.split(',')[:4]
            if key == 'state' and value == 'running':
                hosts.append(host)
    except:
        # Catch errors if vagrant not available
        pass

    return hosts


def get_host_details(host):
    cmd = "vagrant ssh-config {}".format(host)
    config = paramiko.SSHConfig()
    try:
        # Catch errors if vagrant not available
        p = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
        config.parse(p.stdout)
    except:
        pass
    c = config.lookup(host)
    return {'ansible_host': c['hostname'],
            'ansible_port': c['port'],
            'ansible_user': c['user'],
            'ansible_private_key_file': c['identityfile'][0]}


def main():
    args = parse_args()
    if args.list:
        hosts = list_running_hosts()
        json.dump({'vagrant': hosts, 'test': hosts}, sys.stdout)
    else:
        details = get_host_details(args.host)
        json.dump(details, sys.stdout)

if __name__ == '__main__':
    main()


