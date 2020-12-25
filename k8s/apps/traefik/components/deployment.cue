// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"strings"
)

k8s: serviceaccounts: "traefik-ingress-controller": {}

k8s: pvcs: {
	{[string]: spec: {
		accessModes: ["ReadWriteOnce"]
		resources: requests: storage: "1Gi"
	}}

	// Persistence for Let's Encrypt certificate data.
	"traefik-data": {}
}

k8s: deployments: traefik: {
	metadata: labels: app: "traefik"
	spec: {
		replicas: 1
		strategy: type: "Recreate"
		selector: matchLabels: app: "traefik"
		template: {
			metadata: labels: app: "traefik"
			spec: {
				// The sketchy LoadBalancer implementation in k3s does not support IPv6 and is limited to IPv4.
				// Replace one inconvenience by another by running Traefik in the host network namespace.
				hostNetwork:        true
				serviceAccountName: "traefik-ingress-controller"
				containers: [{
					name:  "traefik"
					image: config.images.traefik

					env: [
						{
							name:  "CLOUDFLARE_DNS_API_TOKEN"
							value: config.cloudflareToken
						},
					]

					_letsencryptStaging: [...]

					_letsencrypt: [
						"--certificatesresolvers.wildcardResolver.acme.dnschallenge=true",
						"--certificatesresolvers.wildcardResolver.acme.dnschallenge.provider=cloudflare",
						"--certificatesresolvers.wildcardResolver.acme.email=\(config.letsencryptAccountMail)",
						"--certificatesresolvers.wildcardResolver.acme.storage=/data/acme.json",
					]

					if config.letsencryptMode == "staging" {
						_letsencryptStaging: [
							"--certificatesresolvers.wildcardResolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory",
						]
					}

					let _namespaces = strings.Join(config.namespacesToWatch, ",")

					args: [
						"--accesslog",
						"--entrypoints.web.Address=:\(config.httpPort)",
						"--entrypoints.websecure.Address=:\(config.httpsPort)",
						"--providers.kubernetescrd=true",
						"--providers.kubernetescrd.allowCrossNamespace=false", // enforce clean separation
						"--providers.kubernetescrd.namespaces=\(_namespaces)",
					] + _letsencrypt + _letsencryptStaging

					volumeMounts: [{
						mountPath: "/data"
						name:      "traefik-data"
					}]
				}]
				restartPolicy: "Always"
				volumes: [{
					name: "traefik-data"
					persistentVolumeClaim: claimName: "traefik-data"
				}]

			}
		}
	}
}
