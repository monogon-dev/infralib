// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

import (
	"encoding/yaml"
	"infralib.monogon.dev/k8s/apps/monitoring/rules"
)

k8s: {
	// This configures OpenShift's internal OAuth server for Prometheus and Alertmanager.
	serviceaccounts: prometheus: {}

	pvcs: {
		{[string]: spec: {
			accessModes: ["ReadWriteOnce"]
			resources: requests: storage: "1Gi"
		}}

		"prometheus-data-claim": {}
	}

	services: prometheus: spec: {
		ports: [{
			name:       "prometheus"
			protocol:   "TCP"
			port:       443
			targetPort: 8443
		}, {
			name:       "prometheusapi"
			protocol:   "TCP"
			port:       9090
			targetPort: 9090
		}]
		selector: app: "prometheus"
	}

	secrets: "prometheus-proxy": stringData: session_secret: config.sessionSecret

	statefulsets: prometheus: spec: {
		updateStrategy: type: "RollingUpdate"
		podManagementPolicy: "Parallel"
		selector: matchLabels: app: "prometheus"
		template: {
			metadata: {
				labels: app: "prometheus"
				name: "prometheus"
			}
			spec: {
				serviceAccountName: "prometheus"
				containers: [
					#proxyContainer & {
						#prefix:         "prometheus"
						#serviceAccount: "prometheus"
						#frontendPort:   8443
						#backendPort:    9090
						#extraArgs: ["-skip-auth-regex=^/metrics"]
					},
					#proxyContainer & {
						#prefix:         "alerts"
						#serviceAccount: "prometheus"
						#frontendPort:   9443
						#backendPort:    9093
					},
					{
						name: "prometheus"
						args: [
							"--storage.tsdb.retention=30d",
							"--config.file=/etc/prometheus/prometheus.yml",
							"--web.listen-address=:9090",
							"--web.enable-lifecycle",
						]
						image:           config.images.prometheus
						imagePullPolicy: "IfNotPresent"
						ports: [{
							containerPort: 9090
							name:          "api"
						}]
						volumeMounts: [{
							mountPath: "/etc/prometheus"
							name:      "prometheus-config"
						}, {
							mountPath: "/prometheus"
							name:      "prometheus-data"
						}]
					}, {
						name: "prometheus-reloader"
						args: [
							"--reload-url=http://127.0.0.1:9090/-/reload",
							"--rules-dir=/etc/prometheus",
						]
						image:           config.images.configreloader
						imagePullPolicy: "IfNotPresent"
						volumeMounts: [{
							mountPath: "/etc/prometheus"
							name:      "prometheus-config"
						}]
					}, {
						name: "alertmanager"
						args: [
							"--config.file=/etc/alertmanager/alertmanager.yml",
							"--log.level=debug",
						]
						image:           config.images.alertmanager
						imagePullPolicy: "IfNotPresent"
						ports: [{
							containerPort: 9093
							name:          "web"
						}]
						volumeMounts: [{
							mountPath: "/etc/alertmanager"
							name:      "alertmanager-config"
						}, {
							mountPath: "/alertmanager"
							name:      "alertmanager-data"
						}]
					}, {
						name: "alertmanager-reloader"
						args: [
							"--config-file=/etc/alertmanager/alertmanager.yml",
							"--reload-url=http://127.0.0.1:9093/-/reload",
						]
						image:           config.images.configreloader
						imagePullPolicy: "IfNotPresent"
						volumeMounts: [{
							mountPath: "/etc/alertmanager"
							name:      "alertmanager-config"
						}]
					}]

				restartPolicy: "Always"
				volumes: [{
					name: "prometheus-config"
					configMap: {
						defaultMode: 420
						name:        "prometheus"
					}
				}, {
					name: "prometheus-secrets"
					secret: secretName: "prometheus-proxy"
				}, {
					name: "prometheus-tls"
					secret: secretName: "prometheus-tls"
				}, {
					name: "prometheus-data"
					persistentVolumeClaim: claimName: "prometheus-data-claim"
				}, {
					name: "alertmanager-config"
					configMap: {
						defaultMode: 420
						name:        "alertmanager"
					}
				}, {
					name: "alerts-secrets"
					secret: secretName: "prometheus-alerts-proxy"
				}, {
					name: "alerts-tls"
					secret: secretName: "prometheus-alerts-tls"
				}, {
					name: "alertmanager-data"
					emptyDir: {}
				}]
			}
		}
	}

	services: "prometheus-alerts": spec: {
		ports: [{
			name:       "alerts"
			port:       443
			protocol:   "TCP"
			targetPort: 9443
		}]
		selector: app: "prometheus"
	}

	secrets: "prometheus-alerts-proxy": stringData: session_secret: config.sessionSecret

	configmaps: prometheus: data: {
		"prometheus.yml": yaml.Marshal({
			global: evaluation_interval: "1s"

			rule_files: [
				"*.rules",
			]

			scrape_configs: [{
				job_name:        "prometheus"
				scrape_interval: "5s"
				static_configs: [{
					targets: ["localhost:9090"]}]
			}] + config.scrapeConfigs

			alerting: alertmanagers: [{
				scheme: "http"
				static_configs: [{
					targets: ["localhost:9093"]
				}]
			}]
		})

		_rules: rules & {ruleConfig: config.ruleParameters}

		"alerting.rules": yaml.Marshal({
			groups: [ for k, v in _rules.rules {v}]
		})

		"threshold.rules": yaml.Marshal({
			groups: [ for k, v in config.thresholdRules {v}]
		})
	}

	configmaps: alertmanager: data: "alertmanager.yml": yaml.Marshal(config.alertmanagerConfig)
}
