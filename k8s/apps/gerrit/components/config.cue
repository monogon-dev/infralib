// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#Config: {
	images: {
		gerrit: "docker.io/gerritcodereview/gerrit:3.3.1@sha256:72b0c95042c8dd2bed0f021661ce967c3e4c004275500510de3e39fb4e18aa27"
	}

	// Hostname for Gerrit to run on (without https://)
	publicHostname: string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// UUID4 which identifies this instance.
	serverID: string
}

config: #Config
