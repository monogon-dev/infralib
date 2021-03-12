// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: rolebindings: {
	"cert-manager-cainjector:leaderelection": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
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
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "Role"
			name:     "cert-manager-cainjector:leaderelection"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager-cainjector"
			namespace: "cert-manager"
		}]
	}
	"cert-manager:leaderelection": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
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
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "Role"
			name:     "cert-manager:leaderelection"
		}
		subjects: [{
			apiGroup:  ""
			kind:      "ServiceAccount"
			name:      "cert-manager"
			namespace: "cert-manager"
		}]
	}
	"cert-manager-webhook:dynamic-serving": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
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
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "Role"
			name:     "cert-manager-webhook:dynamic-serving"
		}
		subjects: [{
			apiGroup:  ""
			kind:      "ServiceAccount"
			name:      "cert-manager-webhook"
			namespace: "cert-manager"
		}]
	}
}
