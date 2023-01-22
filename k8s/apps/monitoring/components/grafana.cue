// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"encoding/yaml"
	"strings"
	"strconv"
)

// https://github.com/grafana/grafana/blob/master/docs/sources/administration/provisioning.md
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

	services: grafana: spec: {
		ports: [{
			name:       "grafana"
			protocol:   "TCP"
			port:       80
			targetPort: 3000
		}]
		selector: app: "grafana"
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
				containers: [
					{
						name:            "grafana"
						image:           config.images.grafana
						imagePullPolicy: "IfNotPresent"

						_googleAuth: [
							{
								name:  "GF_AUTH_GOOGLE_ENABLED"
								value: "true"
							},
							{
								name:  "GF_AUTH_GOOGLE_CLIENT_ID"
								value: config.googleAuth.clientID
							},
							{
								name:  "GF_AUTH_GOOGLE_CLIENT_SECRET"
								value: config.googleAuth.clientSecret
							},
							{
								name:  "GF_AUTH_GOOGLE_SCOPES"
								value: "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email"
							},
							{
								name:  "GF_AUTH_GOOGLE_AUTH_URL"
								value: "https://accounts.google.com/o/oauth2/auth"
							},
							{
								name:  "GF_AUTH_GOOGLE_TOKEN_URL"
								value: "https://accounts.google.com/o/oauth2/token"
							},
							{
								name:  "GF_AUTH_GOOGLE_ALLOWED_DOMAINS"
								value: strings.Join(config.googleAuth.allowedDomains, " ")
							},
							{
								name:  "GF_AUTH_GOOGLE_ALLOW_SIGN_UP"
								value: strconv.FormatBool(config.googleAuth.allowSignup)
							},
						]

						env: [
							{
								name:  "GF_SERVER_ROOT_URL"
								value: "https://\(config.publicHostnames.grafana)"
							},
							{
								name:  "GF_INSTALL_PLUGINS"
								value: "natel-discrete-panel 0.0.9"
							},
							{
								name:  "GF_SECURITY_SECRET_KEY"
								value: config.sessionSecret
							},
							{
								name:  "GF_SECURITY_DISABLE_GRAVATAR"
								value: "true"
							},
							{
								name:  "GF_SESSION_COOKIE_SECURE"
								value: "true"
							},
							{
								name:  "GF_SECURITY_COOKIE_SECURE"
								value: "true"
							},
							{
								name:  "GF_SECURITY_STRICT_TRANSPORT_SECURITY"
								value: "true"
							},
							{
								name:  "GF_USERS_AUTO_ASSIGN_ORG_ROLE"
								value: "Admin"
							},
							{
								name:  "GF_ANALYTICS_CHECK_FOR_UPDATES"
								value: "false"
							},
							{
								name:  "GF_DATE_FORMATS_DEFAULT_TIMEZONE"
								value: "UTC"
							},
							{
								name:  "GF_USERS_DEFAULT_THEME"
								value: "light"
							},

						] + _googleAuth

						ports: [{
							protocol:      "TCP"
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
				}]
			}
		}
	}
}

k8s: ingressroutes: "grafana-tls": {
	spec: {
		entryPoints: ["websecure"]
		routes: [
			{
				match: "Host(`\(config.publicHostnames.grafana)`) && PathPrefix(`/`)"
				kind:  "Rule"
				services: [
					{
						kind:     "Service"
						name:     "grafana"
						port:     80
					},
				]
			},
		]
	}
}
