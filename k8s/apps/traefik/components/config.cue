// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#Config: {
	images: {
		traefik: "docker.io/traefik:v2.5.2@sha256:b8802f19de00e344ae5f87d8dde9ff17360a10cf0d5e85949a065de89e69bbe3"
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
