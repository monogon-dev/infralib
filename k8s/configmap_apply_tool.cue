// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package monitoring

import (
	"encoding/yaml"
)

command: "reload-configmaps": {
	task: apply: {
		kind: "exec"
		cmd:  "kubectl apply --validate=false -f -"
		_objects: [ for v in [k8s.configmaps] for x in v {x}]
		stdin:  yaml.MarshalStream(_objects)
		stdout: string
	}
	task: applyDisplay: {
		kind: "print"
		text: task.apply.stdout
	}
}
