// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"infralib.monogon.dev/k8s/base"
)

k8s: base.#KubernetesBase

// Assume that StatefulSets are always named same as the service.
k8s: statefulsets: [Name=string]: spec: serviceName: Name

// Use wildcard domain for all ingresses.
k8s: ingressroutes: [_]: spec: {
	tls: {
		certResolver: "wildcardResolver"
		domains: [
			{
				main: config.publicDomain
				sans: ["*.\(config.publicDomain)"]
			},
		]
	}
}
