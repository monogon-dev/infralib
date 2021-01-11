// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#Config: {
	images: {
		gerrit: "gcr.io/nexantic-infra/gerrit:3.3.1-1@sha256:823731789f827706ebe20c0f59646008b0eca81bdeedb021e1c1b6b210e3e991"
	}

	// Hostname for Gerrit to run on (without https://)
	publicHostname: string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// UUID4 which identifies this instance.
	serverID: string
}

config: #Config
