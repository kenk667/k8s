#!/usr/bin/env bash

set -e
set -x

export GOROOT=/usr/local/go
mkdir go_project && export GOPATH=$HOME/go_projects/
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
echo go version && echo go env
go get github.com/mattn/goreman