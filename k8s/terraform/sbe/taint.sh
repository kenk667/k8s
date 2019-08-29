#!/bin/sh

set -e
MGMT='management'
SVC='services'
TOOLS='tools'
PRIV='private'
PUB='public'


terraform taint -allow-missing module.${MGMT}_vpc.aws_route.${PUB}_subnets_route
terraform taint -allow-missing module.${MGMT}_vpc.aws_route.${PRIV}_subnets_route
terraform taint -allow-missing module.${SVC}_vpc.aws_route.${PUB}_subnets_route
terraform taint -allow-missing module.${SVC}_vpc.aws_route.${PRIV}_subnets_route
terraform taint -allow-missing module.${TOOLS}_vpc.aws_route.${PUB}_subnets_route
terraform taint -allow-missing module.${TOOLS}_vpc.aws_route.${PRIV}_subnets_route