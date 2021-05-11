// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"crypto/sha256"
	"encoding/hex"
	"list"
	"strings"

	"infralib.monogon.dev/k8s/base"
)

k8s: base.#KubernetesBase

// Generate deployment labels and selectors based on deployment name.
// TODO(q3k): merge this into //k8s/base?
k8s: deployments: [Name=string]: spec: {
	selector: matchLabels: app: Name
	template: metadata: {
		labels: app: Name
		name: Name
	}
}
k8s: statefulsets: [Name=string]: spec: {
	selector: matchLabels: app: Name
	template: metadata: {
		labels: app: Name
		name: Name
	}
}

// Generate hidden sha256sum field of every configmap/secret - this can be used
// to make deployments automatically restart on configmap/secret change by
// putting the generated sum into an environment variable.
// TODO(q3k): make this into a mixin and move somewhere to be reusable?
k8s: [Type=("configmaps" | "secrets")]: [Name=string]: {
	// Make sorted list of the configmap's data field names.
	let keys = list.SortStrings([ for k, _ in k8s[Type][Name].data {k}])

	// Make associative array (struct) from field into into hex-encoded sha256sum of the contents of that field.
	let keyToContentSum = {for k, v in k8s[Type][Name].data {"\(k)": hex.Encode(sha256.Sum256(v))}}

	// Make sum of all fields, by hashing ','-joined pairs of '<fieldName>:<fieldSha256>'.
	let fullSum = hex.Encode(sha256.Sum256(strings.Join([ for k in keys {"\(k):\(keyToContentSum[k])"}], ",")))

	// Export the full and per-file sums to CUE users.
	_dataSum: close({
		// Sum of entire configmap.
		full: fullSum
		// Map from data field name to its hash.
		perFile: keyToContentSum
	})
}

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

// Assume that StatefulSets are always named same as the service.
k8s: statefulsets: [Name=string]: spec: serviceName: Name
