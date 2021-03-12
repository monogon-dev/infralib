// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: services: {
	"cert-manager": {
		apiVersion: "v1"
		kind:       "Service"
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
			ports: [{
				port:       9402
				protocol:   "TCP"
				targetPort: 9402
			}]
			selector: {
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			type: "ClusterIP"
		}
	}
	"cert-manager-webhook": {
		apiVersion: "v1"
		kind:       "Service"
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
			ports: [{
				name:       "https"
				port:       443
				targetPort: 10250
				protocol:   "TCP"
			}]
			selector: {
				"app.kubernetes.io/component": "webhook"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "webhook"
			}
			type: "ClusterIP"
		}
	}
}
