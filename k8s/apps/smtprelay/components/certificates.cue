// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

k8s: certificates: "smtprelay-cert": {
	spec: {
		secretName: "smtprelay-cert-secret"
		dnsNames: [config.hostname]
		issuerRef: {
			name:  "letsencrypt-cf-issuer"
			kind:  "ClusterIssuer"
			group: "cert-manager.io"
		}
	}
}
