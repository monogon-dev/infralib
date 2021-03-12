// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: deployments: {
	"cert-manager-cainjector": {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			labels: {
				app:                           "cainjector"
				"app.kubernetes.io/component": "cainjector"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cainjector"
			}
			name:      "cert-manager-cainjector"
			namespace: "cert-manager"
		}
		spec: {
			replicas: 1
			selector: matchLabels: {
				"app.kubernetes.io/component": "cainjector"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cainjector"
			}
			template: {
				metadata: labels: {
					app:                           "cainjector"
					"app.kubernetes.io/component": "cainjector"
					"app.kubernetes.io/instance":  "cert-manager"
					"app.kubernetes.io/name":      "cainjector"
				}
				spec: {
					containers: [{
						args: ["--v=2", "--leader-election-namespace=kube-system"]
						env: [{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						}]
						image:           "quay.io/jetstack/cert-manager-cainjector:v1.1.0@sha256:5cd541e0af815c81b24e8ff3721257a0e309faecf78913774b58ca71984c4a46"
						imagePullPolicy: "IfNotPresent"
						name:            "cert-manager"
						resources: {}
					}]
					serviceAccountName: "cert-manager-cainjector"
				}
			}
		}
	}
	"cert-manager": {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name:      "cert-manager"
			namespace: "cert-manager"
		}
		spec: {
			replicas: 1
			selector: matchLabels: {
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			template: {
				metadata: {
					annotations: {
						"prometheus.io/path":   "/metrics"
						"prometheus.io/port":   "9402"
						"prometheus.io/scrape": "true"
					}
					labels: {
						app:                           "cert-manager"
						"app.kubernetes.io/component": "controller"
						"app.kubernetes.io/instance":  "cert-manager"
						"app.kubernetes.io/name":      "cert-manager"
					}
				}
				spec: {
					containers: [{
						args: ["--v=2", "--cluster-resource-namespace=$(POD_NAMESPACE)", "--leader-election-namespace=kube-system"]
						env: [{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						}]
						image:           "quay.io/jetstack/cert-manager-controller:v1.1.0@sha256:153d99b48570b053e599a03b918dbc80406ba1cf2137f14d5a80a9c7043ac06b"
						imagePullPolicy: "IfNotPresent"
						name:            "cert-manager"
						ports: [{
							containerPort: 9402
							protocol:      "TCP"
						}]
						resources: {}
					}]
					serviceAccountName: "cert-manager"
				}
			}
		}
	}
	"cert-manager-webhook": {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {
			labels: {
				app:                           "webhook"
				"app.kubernetes.io/component": "webhook"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "webhook"
			}
			name:      "cert-manager-webhook"
			namespace: "cert-manager"
		}
		spec: {
			replicas: 1
			selector: matchLabels: {
				"app.kubernetes.io/component": "webhook"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "webhook"
			}
			template: {
				metadata: labels: {
					app:                           "webhook"
					"app.kubernetes.io/component": "webhook"
					"app.kubernetes.io/instance":  "cert-manager"
					"app.kubernetes.io/name":      "webhook"
				}
				spec: {
					containers: [{
						args: ["--v=2", "--secure-port=10250", "--dynamic-serving-ca-secret-namespace=$(POD_NAMESPACE)", "--dynamic-serving-ca-secret-name=cert-manager-webhook-ca", "--dynamic-serving-dns-names=cert-manager-webhook,cert-manager-webhook.cert-manager,cert-manager-webhook.cert-manager.svc"]
						env: [{
							name: "POD_NAMESPACE"
							valueFrom: fieldRef: fieldPath: "metadata.namespace"
						}]
						image:           "quay.io/jetstack/cert-manager-webhook:v1.1.0@sha256:4dd372a988c2a1287c72bac0e73987f6ab97c9b6b9551218f529b463acfbe711"
						imagePullPolicy: "IfNotPresent"
						livenessProbe: {
							failureThreshold: 3
							httpGet: {
								path:   "/livez"
								port:   6080
								scheme: "HTTP"
							}
							initialDelaySeconds: 60
							periodSeconds:       10
							successThreshold:    1
							timeoutSeconds:      1
						}
						name: "cert-manager"
						ports: [{
							containerPort: 10250
							name:          "https"
							protocol:      "TCP"
						}]
						readinessProbe: {
							failureThreshold: 3
							httpGet: {
								path:   "/healthz"
								port:   6080
								scheme: "HTTP"
							}
							initialDelaySeconds: 5
							periodSeconds:       5
							successThreshold:    1
							timeoutSeconds:      1
						}
						resources: {}
					}]
					serviceAccountName: "cert-manager-webhook"
				}
			}
		}
	}
}
