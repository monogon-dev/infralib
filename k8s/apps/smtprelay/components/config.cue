// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

// See smtprelay documentation (our fork replaces the hashed password by a token)
#AuthUser: {
	username:         string & =~"^[a-z-]+$"
	token:            string
	allowedAddresses: *"" | string // defaults to no restrictions
}

#Config: {
	images: {
		smtprelay: "gcr.io/nexantic-infra/smtprelay:1.5.0-1@sha256:c0eeee2165cecd98e7d5ce23112729707e11823022a87ec5171a43a2f3843929"
	}

	// List of CIDRs ranges to allow to send mail.
	allowedNets: [...string]

	// host:port of SMTP server to forward to. No authentication is used.
	outboundHost: string

	// SMTP listen port (in the host namespace)
	listenPort: *25 | uint

	// Relay's SMTP hostname
	hostname: string

	// List of allowed users
	authUsers: [#AuthUser, ...#AuthUser]
}

config: #Config
