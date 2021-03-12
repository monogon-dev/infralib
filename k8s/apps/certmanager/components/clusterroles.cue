// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: clusterroles: {
	"cert-manager-cainjector": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                           "cainjector"
				"app.kubernetes.io/component": "cainjector"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cainjector"
			}
			name: "cert-manager-cainjector"
		}
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["certificates"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["get", "create", "update", "patch"]
		}, {
			apiGroups: ["admissionregistration.k8s.io"]
			resources: ["validatingwebhookconfigurations", "mutatingwebhookconfigurations"]
			verbs: ["get", "list", "watch", "update"]
		}, {
			apiGroups: ["apiregistration.k8s.io"]
			resources: ["apiservices"]
			verbs: ["get", "list", "watch", "update"]
		}, {
			apiGroups: ["apiextensions.k8s.io"]
			resources: ["customresourcedefinitions"]
			verbs: ["get", "list", "watch", "update"]
		}, {
			apiGroups: ["auditregistration.k8s.io"]
			resources: ["auditsinks"]
			verbs: ["get", "list", "watch", "update"]
		}]
	}
	"cert-manager-controller-issuers": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-issuers"
		}
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["issuers", "issuers/status"]
			verbs: ["update"]
		}, {
			apiGroups: ["cert-manager.io"]
			resources: ["issuers"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch", "create", "update", "delete"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["create", "patch"]
		}]
	}
	"cert-manager-controller-clusterissuers": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-clusterissuers"
		}
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["clusterissuers", "clusterissuers/status"]
			verbs: ["update"]
		}, {
			apiGroups: ["cert-manager.io"]
			resources: ["clusterissuers"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch", "create", "update", "delete"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["create", "patch"]
		}]
	}
	"cert-manager-controller-certificates": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-certificates"
		}
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["certificates", "certificates/status", "certificaterequests", "certificaterequests/status"]
			verbs: ["update"]
		}, {
			apiGroups: ["cert-manager.io"]
			resources: ["certificates", "certificaterequests", "clusterissuers", "issuers"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: ["cert-manager.io"]
			resources: ["certificates/finalizers", "certificaterequests/finalizers"]
			verbs: ["update"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["orders"]
			verbs: ["create", "delete", "get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch", "create", "update", "delete"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["create", "patch"]
		}]
	}
	"cert-manager-controller-orders": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-orders"
		}
		rules: [{
			apiGroups: ["acme.cert-manager.io"]
			resources: ["orders", "orders/status"]
			verbs: ["update"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["orders", "challenges"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: ["cert-manager.io"]
			resources: ["clusterissuers", "issuers"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["challenges"]
			verbs: ["create", "delete"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["orders/finalizers"]
			verbs: ["update"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["create", "patch"]
		}]
	}
	"cert-manager-controller-challenges": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-challenges"
		}
		rules: [{
			apiGroups: ["acme.cert-manager.io"]
			resources: ["challenges", "challenges/status"]
			verbs: ["update"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["challenges"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: ["cert-manager.io"]
			resources: ["issuers", "clusterissuers"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["create", "patch"]
		}, {
			apiGroups: [""]
			resources: ["pods", "services"]
			verbs: ["get", "list", "watch", "create", "delete"]
		}, {
			apiGroups: ["extensions"]
			resources: ["ingresses"]
			verbs: ["get", "list", "watch", "create", "delete", "update"]
		}, {
			apiGroups: ["route.openshift.io"]
			resources: ["routes/custom-host"]
			verbs: ["create"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["challenges/finalizers"]
			verbs: ["update"]
		}, {
			apiGroups: [""]
			resources: ["secrets"]
			verbs: ["get", "list", "watch"]
		}]
	}
	"cert-manager-controller-ingress-shim": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                           "cert-manager"
				"app.kubernetes.io/component": "controller"
				"app.kubernetes.io/instance":  "cert-manager"
				"app.kubernetes.io/name":      "cert-manager"
			}
			name: "cert-manager-controller-ingress-shim"
		}
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["certificates", "certificaterequests"]
			verbs: ["create", "update", "delete"]
		}, {
			apiGroups: ["cert-manager.io"]
			resources: ["certificates", "certificaterequests", "issuers", "clusterissuers"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: ["extensions"]
			resources: ["ingresses"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: ["extensions"]
			resources: ["ingresses/finalizers"]
			verbs: ["update"]
		}, {
			apiGroups: [""]
			resources: ["events"]
			verbs: ["create", "patch"]
		}]
	}
	"cert-manager-view": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                                            "cert-manager"
				"app.kubernetes.io/component":                  "controller"
				"app.kubernetes.io/instance":                   "cert-manager"
				"app.kubernetes.io/name":                       "cert-manager"
				"rbac.authorization.k8s.io/aggregate-to-admin": "true"
				"rbac.authorization.k8s.io/aggregate-to-edit":  "true"
				"rbac.authorization.k8s.io/aggregate-to-view":  "true"
			}
			name: "cert-manager-view"
		}
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["certificates", "certificaterequests", "issuers"]
			verbs: ["get", "list", "watch"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["challenges", "orders"]
			verbs: ["get", "list", "watch"]
		}]
	}
	"cert-manager-edit": {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {
			labels: {
				app:                                            "cert-manager"
				"app.kubernetes.io/component":                  "controller"
				"app.kubernetes.io/instance":                   "cert-manager"
				"app.kubernetes.io/name":                       "cert-manager"
				"rbac.authorization.k8s.io/aggregate-to-admin": "true"
				"rbac.authorization.k8s.io/aggregate-to-edit":  "true"
			}
			name: "cert-manager-edit"
		}
		rules: [{
			apiGroups: ["cert-manager.io"]
			resources: ["certificates", "certificaterequests", "issuers"]
			verbs: ["create", "delete", "deletecollection", "patch", "update"]
		}, {
			apiGroups: ["acme.cert-manager.io"]
			resources: ["challenges", "orders"]
			verbs: ["get", "list", "watch"]
		}]
	}
}
