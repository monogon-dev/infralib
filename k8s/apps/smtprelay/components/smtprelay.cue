// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"strings"
)

let _allowedNets = strings.Join(config.allowedNets, " ")

k8s: {
	statefulsets: smtprelay: spec: {
		selector: matchLabels: app: "smtprelay"
		template: {
			metadata: {
				labels: app: "smtprelay"
				name: "smtprelay"
			}
			spec: {
				// TODO: the k3s ghetto LoadBalancer implementation performs SNAT, breaking -allowed_nets.
				hostNetwork: true
				containers: [
					{
						name:  "smtprelay"
						image: config.images.smtprelay
						args: [
							"-logfile=", // still logs to stdout
							"-hostname=\(config.hostname)",
							"-listen=starttls://[::0]:\(config.listenPort)",
							"-allowed_nets=\(_allowedNets)",
							"-remote_host=\(config.outboundHost)",
						]
						env: [
							{
								name: "SMTPRELAY_TLS_CERT"
								valueFrom: secretKeyRef: {
									name: "smtprelay-cert-secret", key: "tls.crt"
								}
							},
							{
								name: "SMTPRELAY_TLS_KEY"
								valueFrom: secretKeyRef: {
									name: "smtprelay-cert-secret", key: "tls.key"
								}
							},
							{
								name:  "SMTPRELAY_USERS"
								value: strings.Join([ for v in config.authUsers {"\(v.username) \(v.token) \(v.allowedAddresses)"}], "\n")
							},
						]
					},
				]
			}
		}
	}
}
