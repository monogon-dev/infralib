// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package k8s

import "encoding/yaml"

command: diff: {
	task: diff: RemoteTask & {
		kind:  "exec"
		_cmd:  "kubectl diff --server-side --field-manager=infra-cue-apply --force-conflicts=true -f -"
		stdin: yaml.MarshalStream(preObjects + objects)
	}
}