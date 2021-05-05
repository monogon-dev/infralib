// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#GoogleAuth: {
	// Get credentials at https://console.cloud.google.com/apis/credentials
	clientID:     string
	clientSecret: string

	// List of 'employee' Google Workspace domains that can log in. Currently
	// this _must_ be set to at least one domain, as all authenticated users
	// get a set of basic 'employee' permissions that allows to run/cancel
	// builds. Thus, we want to prevent any external-but-logged-in user from
	// being granted these permissions.
	//
	// This approach to permissions might change in the future (and instead
	// non-employees might be allowed to log in, eg. open source contributors),
	// and then this requirement will be relaxed.
	restrictDomains: [string, ...string]
}

#Config: {
	images: {
		controller: "gcr.io/monogon-infra/jenkins:2.77.3-lts-centos7-4"
	}

	// Hostname for Jenkins to run on (without https://)
	publicHostname: string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// Email address of Jenkins administrator. Currently unused, but in the
	// future might receive administrative emails.
	adminAddress: string

	// List of admin accounts, as Google account email addresses. These
	// accounts will have a permission to fully manage the Jenkins installation
	// at runtime. This permission shouldn't need to be exercised often, as all
	// configuration should be managed by code, and is more of a break-glass
	// procedure than anything else.
	admins: [...string]

	googleAuth: #GoogleAuth
}

config: #Config
