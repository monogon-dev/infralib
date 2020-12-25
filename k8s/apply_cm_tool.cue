// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package k8s

import (
	"encoding/yaml"
)

// apply-cm applies configmaps only for better performance during development.
command: "apply-cm": {
	task: apply: RemoteTask & {
		kind: "exec"
		_cmd: "kubectl apply --server-side -f -"
		_objects: [ for v in [context.objects.configmaps] for x in v {x}]
		stdin:  yaml.MarshalStream(_objects)
		stdout: string
	}
	task: applyDisplay: {
		kind: "print"
		text: task.apply.stdout
	}
}
