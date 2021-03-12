#!/usr/bin/env bash

rm go.mod
go mod init infralib.monogon.dev/k8s/base

go get github.com/decke/smtprelay@master

bazel run //:gazelle -- update-repos -from_file=go/go.mod -to_macro=go/deps.bzl%go_repositories
