// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package base

import (
	core_v1 "k8s.io/api/core/v1"
	apps_v1 "k8s.io/api/apps/v1"
	rbac_v1 "k8s.io/api/rbac/v1"
	networking_v1 "k8s.io/api/networking/v1"
	storage_v1 "k8s.io/api/storage/v1"
	admissionregistration_v1 "k8s.io/api/admissionregistration/v1"
	apiext_v1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
)

// Rather than an unordered list, we maintain a map of named objects by type and map it k8s objects.
#KubernetesBase: {
	deploymentNamespace: string

	namespaces: [Name=_]: core_v1.#Namespace & {
		apiVersion: "v1"
		kind:       "Namespace"
		metadata: {name: Name}
	}

	// CRDs

	// TODO: The Traefik CRD does not generate cleanly - enable typechecking against traefik_v1alpha1.#IngressRoute
	ingressroutes: [Name=_]: {
		apiVersion: "traefik.containo.us/v1alpha1"
		kind:       "IngressRoute"
		metadata: {name: Name, namespace: deploymentNamespace}
		...
	}

	// GCP managed certificate CRDs
	managedcertificates: [Name=_]: {
		apiVersion: "networking.gke.io/v1"
		kind:       "ManagedCertificate"
		metadata: {name: Name, namespace: deploymentNamespace}
		spec: {
			domains: [string, ...string]
		}
		...
	}
	// GCP ingress-gce load balancer backend config from:
	//     https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-features
	backendconfigs: [Name=_]: {
		apiVersion: "cloud.google.com/v1"
		kind:       "BackendConfig"
		metadata: {name: Name, namespace: deploymentNamespace}
		spec: {
			iap?: {
				enabled: bool
				oauthclientCredentials: secretName: string
			}
			connectionDraining?: drainingTimeoutSec: number
			customRequestHeaders?: [string, ...string]
			healthCheck?: {
				checkIntervalSec?:   number
				timeoutSec?:         number
				healthyThreshold?:   number
				unhealthyThreshold?: number
				type:                "HTTP" | "HTTPS" | "HTTP2"
				requestPath?:        string
				port?:               number
			}
			logging?: {
				enable:      bool
				sampleRate?: number
			}
			securityPolicy?: name:          string
			sessionAffinity?: affinityType: string
			timeoutSec?: number
		}
		...
	}

	frontendconfigs: [Name=_]: {
		apiVersion: "networking.gke.io/v1beta1"
		kind:       "FrontendConfig"
		metadata: {name: Name, namespace: deploymentNamespace}
		spec: {...}
	}

	// Cert-Manager
	issuers: [Name=_]: {
		apiVersion: "cert-manager.io/v1"
		kind:       "Issuer"
		metadata: {name: Name, namespace: deploymentNamespace}
		...
	}
	clusterissuers: [Name=_]: {
		apiVersion: "cert-manager.io/v1"
		kind:       "ClusterIssuer"
		metadata: {name: Name}
		...
	}
	certificates: [Name=_]: {
		apiVersion: "cert-manager.io/v1"
		kind:       "Certificate"
		metadata: {name: Name, namespace: deploymentNamespace}
		...
	}

	// Core objects
	serviceaccounts: [Name=_]: core_v1.#ServiceAccount & {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	secrets: [Name=_]: core_v1.#Secret & {
		apiVersion: "v1"
		kind:       "Secret"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	configmaps: [Name=_]: core_v1.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	pvcs: [Name=_]: core_v1.#PersistentVolumeClaim & {
		apiVersion: "v1"
		kind:       "PersistentVolumeClaim"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	services: [Name=_]: core_v1.#Service & {
		apiVersion: "v1"
		kind:       "Service"
		metadata: {name: Name, namespace: deploymentNamespace}
		metadata: labels: name: Name
	}

	statefulsets: [Name=_]: apps_v1.#StatefulSet & {
		apiVersion: "apps/v1"
		kind:       "StatefulSet"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	deployments: [Name=_]: apps_v1.#Deployment & {
		apiVersion: "apps/v1"
		kind:       "Deployment"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	mutatingwebhookconfigurations: [Name=_]: admissionregistration_v1.#MutatingWebhookConfiguration & {
		apiVersion: "admissionregistration.k8s.io/v1"
		kind:       "MutatingWebhookConfiguration"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	validatingwebhookconfigurations: [Name=_]: admissionregistration_v1.#ValidatingWebhookConfiguration & {
		apiVersion: "admissionregistration.k8s.io/v1"
		kind:       "ValidatingWebhookConfiguration"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	clusterrolebindings: [Name=_]: rbac_v1.#ClusterRoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRoleBinding"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	clusterroles: [Name=_]: rbac_v1.#ClusterRole & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "ClusterRole"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	rolebindings: [Name=_]: rbac_v1.#RoleBinding & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "RoleBinding"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	roles: [Name=_]: rbac_v1.#Role & {
		apiVersion: "rbac.authorization.k8s.io/v1"
		kind:       "Role"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	crds: [Name=_]: apiext_v1.#CustomResourceDefinition & {
		apiVersion: "apiextensions.k8s.io/v1"
		kind:       "CustomResourceDefinition"
		metadata: {name: Name, namespace: deploymentNamespace}
	}
	ingresses: [Name=_]: networking_v1.#Ingress & {
		apiVersion: "networking.k8s.io/v1"
		kind:       "Ingress"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	volumesnapshotclasses: [Name=_]: storage_v1.VolumeSnapshotClass & {
		apiVersion: "snapshot.storage.k8s.io/v1"
		kind:       "VolumeSnapshotClass"
		metadata: {name: Name, namespace: deploymentNamespace}
	}
}
