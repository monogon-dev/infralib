// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package base

import (
	core_v1 "k8s.io/api/core/v1"
	apps_v1 "k8s.io/api/apps/v1"
	rbac_v1 "k8s.io/api/rbac/v1"
	apiext_v1beta1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1beta1"
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

	crdsLegacy: [Name=_]: apiext_v1beta1.#CustomResourceDefinition & {
		apiVersion: "apiextensions.k8s.io/v1beta1"
		kind:       "CustomResourceDefinition"
		metadata: {name: Name, namespace: deploymentNamespace}
	}

	crds: [Name=_]: apiext_v1.#CustomResourceDefinition & {
		apiVersion: "apiextensions.k8s.io/v1"
		kind:       "CustomResourceDefinition"
		metadata: {name: Name, namespace: deploymentNamespace}
	}
}
