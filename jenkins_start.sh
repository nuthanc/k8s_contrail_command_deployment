#!/bin/bash -ex

sshpass -p 'c0ntrail123' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $SANITY_NODE "source" <./run_sanity.sh