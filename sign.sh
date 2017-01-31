#!/bin/sh 
# set -x
set -e

REQ=$1
CSR=$REQ.csr

test -f $CSR  || (echo Can\'t find $CSR. Aborting; exit 1)

make sign REQ=$1