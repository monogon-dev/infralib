// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#Config: {
	images: {
		traefik: "docker.io/traefik:v2.9.6@sha256:bb7be8d50edf73d8d3a812ac8873ef354a0fe9b40d7f3880747b43a3525855d2"
	}

	// Cloudflare access token for Let's Encrypt DNS challenges.
	cloudflareToken: string

	// CRDs that aren't in any of these namespaces will be ignored. Note that those
	// namespaces will be able to request certificates for any domain that the CloudFlare API key has access to.
	namespacesToWatch: [...string]

	letsencryptMode:        "staging" | "production" // beware of rate limits
	letsencryptAccountMail: string

	httpPort:  uint | *80
	httpsPort: uint | *443
}

config: #Config
