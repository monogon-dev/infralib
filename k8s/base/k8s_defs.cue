// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package base

import (
	core_v1 "k8s.io/api/core/v1"
)

// Rather than an unordered list, we maintain a map of named objects by type and map it k8s objects.
#KubernetesBase: {
	serviceaccounts: [Name=_]: core_v1.#ServiceAccount & {
		apiVersion: "v1"
		kind:       "ServiceAccount"
		metadata: name: Name
	}

	secrets: [Name=_]: core_v1.#Secret & {
		apiVersion: "v1"
		kind:       "Secret"
		metadata: name: Name
	}

	configmaps: [Name=_]: core_v1.#ConfigMap & {
		apiVersion: "v1"
		kind:       "ConfigMap"
		metadata: name: Name
	}

	pvcs: [Name=_]: core_v1.#PersistentVolumeClaim & {
		apiVersion: "v1"
		kind:       "PersistentVolumeClaim"
		metadata: name: Name
	}

	services: [Name=_]: core_v1.#Service & {
		apiVersion: "v1"
		kind:       "Service"
		metadata: name: Name
		metadata: labels: name: Name
	}

	// TODO: This should be route_v1.Route, but OpenShift does something funny with its schema definition
	// where the host field is marked required, but can be left out during creation
	// (kubectl also fails to validate the resulting object, oc is happy about it).
	routes: [Name=_]: {
		apiVersion: "route.openshift.io/v1"
		kind:       "Route"
		metadata: name: Name
		spec: {
			host: string | *null // Cluster generates a host name if empty
			to: name: string
			...
		}
	}

	imagestreams: [Name=_]: {
		apiVersion: "image.openshift.io/v1"
		kind:       "ImageStream"
		metadata: name: Name
		...
	}

	// TODO: This should be apps_v1.StatefulSet, but OpenShift 3.11 is on betav1, which does not match
	statefulsets: [Name=_]: {
		apiVersion: "apps/v1beta1"
		kind:       "StatefulSet"
		metadata: name: Name
		...
	}
}
