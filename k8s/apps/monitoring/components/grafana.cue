// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"encoding/json"
	"encoding/yaml"
)

#DatasourceConfig: datasources: [...{
	name:      string
	type:      string
	url:       string
	access:    *"proxy" | "direct"
	user?:     string
	isDefault: *true | bool
	secureJsonData?: password: string
}]

// Default prometheus config
datasource_config: #DatasourceConfig & {
	datasources: [{
		name: "Main Prometheus"
		type: "prometheus"
		url:  "http://prometheus:9090"
	}]
}

k8s: {
	pvcs: "grafana-data-claim": {}

	configmaps: "grafana-datasources": data: "prometheus.yaml": yaml.Marshal(datasource_config)

	secrets: "grafana-proxy": stringData: session_secret: config.sessionSecret

	serviceaccounts: grafana: metadata: annotations: "serviceaccounts.openshift.io/oauth-redirectreference.grafana": json.Marshal({
		kind:       "OAuthRedirectReference"
		apiVersion: "v1"
		reference: {
			kind: "Route"
			name: "grafana"
		}})

	services: grafana: spec: {
		ports: [{
			name:       "grafana"
			protocol:   "TCP"
			port:       443
			targetPort: 8443
		}]
		selector: app: "grafana"
	}

	routes: grafana: spec: {
		port: targetPort: "grafana"
		to: name:         "grafana"
		tls: {
			termination:                   "Reencrypt"
			insecureEdgeTerminationPolicy: "Redirect"
		}
	}

	statefulsets: grafana: spec: {
		updateStrategy: type: "RollingUpdate"
		podManagementPolicy: "Parallel"
		selector: matchLabels: app: "grafana"
		template: {
			metadata: {
				labels: app: "grafana"
				name: "grafana"
			}
			spec: {
				serviceAccountName: "grafana"
				containers: [
					#proxyContainer & {
						#prefix:         "grafana"
						#serviceAccount: #prefix
						#frontendPort:   8443
						#backendPort:    3000
					},
					{
						name:            "grafana"
						image:           config.images.grafana
						imagePullPolicy: "IfNotPresent"
						env: [{
							name:  "GF_AUTH_PROXY_ENABLED"
							value: "true"
						}, {
							name:  "GF_AUTH_PROXY_HEADER_NAME"
							value: "X-Forwarded-Email"
						}, {
							name:  "GF_AUTH_PROXY_HEADER_PROPERTY"
							value: "email"
						}, {
							name:  "GF_USERS_AUTO_ASSIGN_ORG_ROLE"
							value: "Admin"
						}, {
							name:  "GF_INSTALL_PLUGINS"
							value: "natel-discrete-panel 0.0.9"
						}]
						ports: [{
							containerPort: 3000
							name:          "grafana"
						}]
						volumeMounts: [{
							mountPath: "/var/lib/grafana"
							name:      "grafana-data"
						}, {
							mountPath: "/etc/grafana/provisioning/datasources"
							name:      "grafana-datasources"
						}]
					},
				]

				restartPolicy: "Always"
				volumes: [{
					name: "grafana-datasources"
					configMap: name: "grafana-datasources"
				}, {
					name: "grafana-data"
					persistentVolumeClaim: claimName: "grafana-data-claim"
				}, {
					name: "grafana-secrets"
					secret: secretName: "grafana-proxy"
				}, {
					name: "grafana-tls"
					secret: secretName: "grafana-tls"
				}]
			}
		}
	}
}
