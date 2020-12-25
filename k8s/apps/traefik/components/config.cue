// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#Config: {
	images: {
		traefik: "docker.io/traefik:v2.3.6@sha256:03e2149c3a844ca9543edd2a7a8cd0e4a1a9afb543486ad99e737323eb5c25f2"
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
