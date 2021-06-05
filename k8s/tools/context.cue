// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package tools

import (
	"infralib.monogon.dev/k8s/base"
)

// A context describes an individual deployment of Kubernetes objects to a namespace in a Kubernetes cluster.
#Context: {
	// Full map of Kubernetes objects to deploy. We deploy with --prune=true, so it needs to be a complete list.
	objects: base.#KubernetesBase

	// Namespace to deploy the objects to. This is ignored for cluster-global objects, if any are defined.
	namespace: string

	// kubectl context to deploy to. This context is defined by the kubectl configuration of the local or remote host.
	// Local contexts should be uniquely named to prevent ambiguity and deployment to the wrong host.
	context: string | *"default"

	// SSH remote host to deploy the objects to by invoking a remote kubectl command, or "local" to use the local kubectl.
	hostname: string | "local"

	// Set namespace on all objects.
	//
	// The naive solution at the tool layer:
	//   context: objects: [_]: [_]: metadata: namespace: context.namespace
	//
	// ...also happens to be painfully slow, increasing runtime by 10x. Therefore, we instead
	// explicitly set the namespace for each kind in k8s_defs.cue and set that here.
	objects: deploymentNamespace: *namespace | "kube-system"

	// Specified namespace is created by default
	objects: namespaces: "\(namespace)": {}
}
