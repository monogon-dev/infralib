// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#Config: {
	// Cloudflare access token for Let's Encrypt DNS challenges.
	cloudflareToken: string

	letsencryptMode:        "staging" | "production" // beware of rate limits
	letsencryptAccountMail: string
}

config: #Config
