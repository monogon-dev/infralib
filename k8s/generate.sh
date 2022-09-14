#!/usr/bin/env bash
set -euo pipefail
# Regenerate all definition from latest releases, including the dummy Go module which is used to pin dependencies.

rm -rf cue.mod/gen
go mod tidy

# Generate Cue definitions (see deps.go)
cue get go github.com/prometheus/prometheus/pkg/rulefmt
cue get go k8s.io/api/apps/v1
cue get go k8s.io/api/core/v1
cue get go k8s.io/api/rbac/v1
cue get go k8s.io/api/admissionregistration/v1
cue get go k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1beta1
cue get go k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1
cue get go k8s.io/api/networking/v1
cue get go k8s.io/api/storage/v1
