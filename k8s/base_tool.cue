// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package k8s

objects: [ for v in objectSets for x in v {x}]

objectSets: [
	k8s.serviceaccounts,
	k8s.secrets,
	k8s.configmaps,
	k8s.pvcs,
	k8s.services,
	k8s.routes,
	k8s.statefulsets,
	k8s.imagestreams,
]
