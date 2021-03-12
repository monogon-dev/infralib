// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: roles: {
	"cert-manager-cainjector:leaderelection": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "Role"
		metadata: {
			labels: {
				app:                           "cainjector"
				"app.kubernetes.io/component": "cainjector"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cainjector"
			}
			name:      "cert-manager-cainjector:leaderelection"
			namespace: "kube-system"
		}
		rules: [{
			apiGroups: [""]
			resourceNames: ["cert-manager-cainjector-leader-election", "cert-manager-cainjector-leader-election-core"]
			resources: ["configmaps"]
			verbs: ["get", "update", "patch"]
		}, {
			apiGroups: [""]
			resources: ["configmaps"]
			verbs: ["create"]
		}]
	}
	"cert-manager:leaderelection": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "Role"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name:      "cert-manager:leaderelection"
			namespace: "kube-system"
		}
		rules: [{
			apiGroups: [""]
			resourceNames: ["cert-manager-controller"]
			resources: ["configmaps"]
			verbs: ["get", "update", "patch"]
		}, {
			apiGroups: [""]
			resources: ["configmaps"]
			verbs: ["create"]
		}]
	}
	"cert-manager-webhook:dynamic-serving": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "Role"
		metadata: {
			labels: {
				app:                           "webhook"
				"app.kubernetes.io/component": "webhook"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "webhook"
			}
			name:      "cert-manager-webhook:dynamic-serving"
			namespace: "cert-manager"
		}
		rules: [{
			apiGroups: [""]
			resourceNames: ["cert-manager-webhook-ca"]
			resources: ["secrets"]
			verbs: ["get", "list", "watch", "update"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["create"]
		}]
	}
}
