// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package tools

// get-pod-requests shows CPU and memory requests for each pod in the context's namespace.
command: "get-pod-requests": {
	task: diff: RemoteTask & {
		kind:     "exec"
		_kubectl: string
		_cmd:     _kubectl + "-n \(context.namespace) get pod -o custom-columns=NAME:.metadata.name,CPU:.spec.containers.*.resources.requests.cpu,MEM:.spec.containers.*.resources.requests.memory"
	}
}
