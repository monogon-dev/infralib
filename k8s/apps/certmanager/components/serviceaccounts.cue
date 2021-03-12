// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: serviceaccounts: {
	"cert-manager-cainjector": {
		apiVersion: "v1"
		kind:       "ServiceAccount"
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
	}
	"cert-manager": {
		apiVersion: "v1"
		kind:       "ServiceAccount"
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
	}
	"cert-manager-webhook": {
		apiVersion: "v1"
		kind:       "ServiceAccount"
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
	}
}
