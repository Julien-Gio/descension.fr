#!/bin/bash
set -e

# install SBCL
apt-get update
apt-get install -y sbcl

rm -rf output
sbcl --script run.lisp