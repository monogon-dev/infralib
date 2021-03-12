// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: clusterrolebindings: {
	"cert-manager-cainjector": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			labels: {
				app:                           "cainjector"
				"app.kubernetes.io/component": "cainjector"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cainjector"
			}
			name: "cert-manager-cainjector"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cert-manager-cainjector"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager-cainjector"
			namespace: "cert-manager"
		}]
	}
	"cert-manager-controller-issuers": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-issuers"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cert-manager-controller-issuers"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager"
			namespace: "cert-manager"
		}]
	}
	"cert-manager-controller-clusterissuers": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-clusterissuers"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cert-manager-controller-clusterissuers"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager"
			namespace: "cert-manager"
		}]
	}
	"cert-manager-controller-certificates": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-certificates"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cert-manager-controller-certificates"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager"
			namespace: "cert-manager"
		}]
	}
	"cert-manager-controller-orders": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-orders"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cert-manager-controller-orders"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager"
			namespace: "cert-manager"
		}]
	}
	"cert-manager-controller-challenges": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-challenges"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cert-manager-controller-challenges"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager"
			namespace: "cert-manager"
		}]
	}
	"cert-manager-controller-ingress-shim": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-ingress-shim"
		}
		roleRef: {
			apiGroup: "rbac.authorization.k8s.io"
			kind:     "ClusterRole"
			name:     "cert-manager-controller-ingress-shim"
		}
		subjects: [{
			kind:      "ServiceAccount"
			name:      "cert-manager"
			namespace: "cert-manager"
		}]
	}
}
