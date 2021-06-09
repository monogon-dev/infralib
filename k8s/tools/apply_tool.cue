// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package tools

import (
	"encoding/yaml"
)

// Use a custom field manager by default in order to conflict with any manually-ran local- or server-side apply.

command: apply: {
	task: prereqs: RemoteTask & {
		kind:     "exec"
		_kubectl: string
		_cmd:     _kubectl + "apply --field-manager=infra-cue-apply --server-side -f -"
		stdin:    yaml.MarshalStream(preObjects)
	}

	task: apply: RemoteTask & {
		$after: task.prereqs

		kind: "exec"

		// TODO: Support --prune=true. Is it safe to use --prune=true with stdin, or can there be a situation where
		// truncated input leads to accidental deletion?  --server-side also doesn't appear to work with --prune. Perhaps we
		// would be better off with a list of objects to delete?

		_kubectl: string
		_cmd:     _kubectl + "apply --field-manager=infra-cue-apply --server-side -f -"
		stdin:    yaml.MarshalStream(objects)
	}

}

// apply-fast skips prereqs (like crds)
command: "apply-fast": RemoteTask & {
	kind:     "exec"
	_kubectl: string
	_cmd:     _kubectl + "apply --field-manager=infra-cue-apply --server-side -f -"
	stdin:    yaml.MarshalStream(objects)
}

// Same as apply, but with --force-conflicts to override rogue field managers.
//
// A common scenario where this is needed is the initial "takeover" of an existing
// configuration hand-deployed using kubectl.
command: "apply-force": RemoteTask & {
	kind:  "exec"
	_cmd:  command.apply.task.apply._cmd + " --force-conflicts"
	stdin: yaml.MarshalStream(objects)
}
