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
		"alertmanager-data-claim": {}
	}

	services: prometheus: spec: {
		ports: [
			{
				name:       "prometheus"
				protocol:   "TCP"
				port:       80
				targetPort: 8000
			},
			{
				name:       "prometheusapi"
				protocol:   "TCP"
				port:       9090
				targetPort: 9090
			},
		]
		selector: app: "prometheus"
	}

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
					proxyContainer & {
						_prefix:       "prometheus"
						_frontendPort: 8000
						_backendPort:  9090
						_extraArgs: ["--skip-auth-regex=^/metrics"]
					},
					proxyContainer & {
						_prefix:         "alerts"
						_serviceAccount: "prometheus"
						_frontendPort:   8001
						_backendPort:    9093
					},
					{
						name: "prometheus"
						args: [
							"--storage.tsdb.retention=30d",
							"--config.file=/etc/prometheus/prometheus.yml",
							"--web.listen-address=:9090",
							"--web.enable-lifecycle",
							"--web.external-url=https://\(config.publicHostnames.prometheus)",
						]
						image:           config.images.prometheus
						imagePullPolicy: "IfNotPresent"
						ports: [{
							containerPort: 9090
							protocol:      "TCP"
							name:          "api"
						}]
						volumeMounts: [
							{
								mountPath: "/etc/prometheus"
								name:      "prometheus-config"
							},
							{
								mountPath: "/prometheus"
								name:      "prometheus-data"
							},
						]
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
							"--web.external-url=https://\(config.publicHostnames.alertmanager)",
						]
						image:           config.images.alertmanager
						imagePullPolicy: "IfNotPresent"
						ports: [{
							containerPort: 9093
							protocol:      "TCP"
							name:          "web"
						}]
						volumeMounts: [
							{
								mountPath: "/etc/alertmanager"
								name:      "alertmanager-config"
							},
							{
								mountPath: "/alertmanager"
								name:      "alertmanager-data"
							},
						]
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
				volumes: [
					{
						name: "prometheus-config"
						configMap: {
							defaultMode: 420
							name:        "prometheus"
						}
					},
					{
						name: "prometheus-data"
						persistentVolumeClaim: claimName: "prometheus-data-claim"
					},
					{
						name: "alertmanager-config"
						configMap: {
							defaultMode: 420
							name:        "alertmanager"
						}
					},
					{
						name: "alertmanager-data"
						persistentVolumeClaim: claimName: "alertmanager-data-claim"
					},
				]
			}
		}
	}

	services: "prometheus-alerts": spec: {
		ports: [{
			name:       "alerts"
			port:       80
			protocol:   "TCP"
			targetPort: 8001
		}]
		selector: app: "prometheus"
	}

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

k8s: ingressroutes: "prom-tls": {
	spec: {
		entryPoints: ["websecure"]
		routes: [
			{
				match: "Host(`\(config.publicHostnames.prometheus)`) && PathPrefix(`/`)"
				kind:  "Rule"
				services: [
					{
						kind:     "Service"
						name:     "prometheus"
						port:     80
						protocol: "TCP"
					},
				]
			},
			{
				match: "Host(`\(config.publicHostnames.alertmanager)`) && PathPrefix(`/`)"
				kind:  "Rule"
				services: [
					{
						kind:     "Service"
						name:     "prometheus-alerts"
						port:     80
						protocol: "TCP"
					},
				]
			},
		]
	}
}
