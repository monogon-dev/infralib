// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#GoogleAuth: {
	// Get credentials at https://console.cloud.google.com/apis/credentials
	clientID:     string
	clientSecret: string
}

#Config: {
	images: {
		gerrit: "gcr.io/nexantic-infra/gerrit:3.3.2-1@sha256:dbe3406149d70b85a75e5f1146b36dd0a47f19ac7291018a0741a72c7270b40b"
	}

	// Hostname for Gerrit to run on (without https://)
	publicHostname: string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// UUID4 which identifies this instance.
	serverID: string

	// Google OAuth credentials
	googleAuth: #GoogleAuth
}

config: #Config
