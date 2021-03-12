// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

k8s: secrets: "cf-api-token": {
	type: "Opaque"
	stringData: "api-token": config.cloudflareToken
}

k8s: clusterissuers: "letsencrypt-cf-issuer": {
	spec: acme: {
		email: config.letsencryptAccountMail

		if config.letsencryptMode == "production" {
			server: "https://acme-v02.api.letsencrypt.org/directory"
		}
		if config.letsencryptMode == "staging" {
			server: "https://acme-staging-v02.api.letsencrypt.org/directory"
		}

		privateKeySecretRef: name: "letsencrypt-cf-issuer-account-key"
		solvers: [{
			dns01: cloudflare: {
				apiTokenSecretRef: {
					name: "cf-api-token"
					key:  "api-token"
				}
			}
		}]
	}
}
