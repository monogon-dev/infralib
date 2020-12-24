// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package k8s

import "encoding/yaml"

command: apply: {
	task: kube: {
		kind: "exec"
		// Upstream kubectl fails to validate OpenShift objects
		cmd:   "kubectl apply --prune=true --all --validate=false -f -"
		stdin: yaml.MarshalStream(objects)
	}
}
