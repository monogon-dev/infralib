// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package tools

import "encoding/yaml"

let diffEnv = #"KUBECTL_EXTERNAL_DIFF="/bin/diff -b -N -u" "#

command: diff: {
	task: diff: RemoteTask & {
		kind:     "exec"
		_kubectl: string
		_cmd:     diffEnv + _kubectl + "diff --server-side --field-manager=infra-cue-apply --force-conflicts=true -f -"
		stdin:    yaml.MarshalStream(preObjects + objects)
	}
}

command: "diff-fast": {
	task: diff: RemoteTask & {
		kind:     "exec"
		_kubectl: string
		_cmd:     diffEnv + _kubectl + "diff --server-side --field-manager=infra-cue-apply --force-conflicts=true -f -"
		stdin:    yaml.MarshalStream(objects)
	}
}
