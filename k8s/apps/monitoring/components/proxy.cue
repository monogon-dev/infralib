// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

proxyContainer: {
	_prefix:       string
	_frontendPort: number
	_backendPort:  number

	name:  "\(_prefix)-proxy"
	image: config.images.proxy

	ports: [{
		containerPort: _frontendPort
		protocol:      "TCP"
		name:          "web"
	}]

	args: [
		"--upstream=http://127.0.0.1:\(_backendPort)",
		"--client-id=\(config.googleAuth.clientID)",
		"--client-secret=\(config.googleAuth.clientSecret)",
		"--cookie-refresh=24h",
		"--banner=yo",
		"--http-address=:\(_frontendPort)",
		"--https-address=",
		"--provider=google",
		"--provider-display-name=Google Workspace SSO",
		"--reverse-proxy=true",
		"--cookie-secret=\(config.sessionSecret)",
	] + _args

	let _args = [
		for d in config.googleAuth.allowedDomains {
			"--email-domain=\(d)"
		},
	]
}
