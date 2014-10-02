#!/usr/bin/python
#
# create_new_node.py
#
# Creates a new Linode instance with the name "Anarchivist"
#

import os
import json
from linode import api

linode = api.Api(os.environ['LINODE_API_KEY'])

node_name          = os.getenv('LINODE_NAME', 'Anarchivist')
node_datacentre_id = os.getenv('LINODE_DATACENTREID', -1)
node_plan_id       = os.getenv('LINODE_PLANID', -1)

node_exists=False
for nodes in linode.linode_list(label=node_name):
    if nodes['LABEL'] == node_name:
        node_exists = True
        node_datacentre_id = nodes['DATACENTREID']
        node_plan_id = nodes['PLANID']

if node_exists:
    print "Found: ", node_name
else:
    print "Creating new node..."
    create_node(linode, node_name, node_datacentre_id, node_plan_id)



def create_node(linode, node_name, datacentre_id, plan_id):
    linode.create(node)
