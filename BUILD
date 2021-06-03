#  Copyright 2020 The Monogon Project Authors.
#  SPDX-License-Identifier: Apache-2.0

load("@bazel_gazelle//:def.bzl", "gazelle")

# gazelle:prefix infralib.monogon.dev
# gazelle:exclude k8s
gazelle(name = "gazelle")

load("//k8s/apps/jenkins/build/plugingen:workspace.bzl", "jenkins_plugingen")
jenkins_plugingen(name = "jenkins_plugingen")
