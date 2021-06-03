// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package tools

import (
	"encoding/yaml"
)

// Use a custom field manager by default in order to conflict with any manually-ran local- or server-side apply.
// TODO: k3s apparently ignores this and always lists "k3s" as the manager?

command: apply: {
	task: prereqs: RemoteTask & {
		kind:  "exec"
		_cmd:  "kubectl apply --field-manager=infra-cue-apply --server-side -f -"
		stdin: yaml.MarshalStream(preObjects)
	}

	task: apply: RemoteTask & {
		$after: task.prereqs

		kind: "exec"

		// TODO: Support --prune=true. Is it safe to use --prune=true with stdin, or can there be a situation where
		// truncated input leads to accidental deletion?  --server-side also doesn't appear to work with --prune. Perhaps we
		// would be better off with a list of objects to delete?

		// TODO: do we want to use --force-conflicts by default? How do we even deal with conflicts? Fix the operator?

		_cmd:  "kubectl apply --field-manager=infra-cue-apply --server-side -f -"
		stdin: yaml.MarshalStream(objects)
	}

}

// apply-fast skips prereqs (like crds)
command: "apply-fast": RemoteTask & {
	kind:  "exec"
	_cmd:  "kubectl apply --field-manager=infra-cue-apply --server-side -f -"
	stdin: yaml.MarshalStream(objects)
}
