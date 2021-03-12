// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

// cuetify import from cert-manager.yaml

package components

k8s: mutatingwebhookconfigurations: "cert-manager-webhook": {
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "MutatingWebhookConfiguration"
	metadata: {
		annotations: "cert-manager.io/inject-ca-from-secret": "cert-manager/cert-manager-webhook-ca"
		labels: {
			app:                           "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "cert-manager"
			"app.kubernetes.io/name":      "webhook"
		}
		name: "cert-manager-webhook"
	}
	webhooks: [{
		admissionReviewVersions: ["v1", "v1beta1"]
		clientConfig: service: {
			name:      "cert-manager-webhook"
			namespace: "cert-manager"
			path:      "/mutate"
		}
		failurePolicy: "Fail"
		name:          "webhook.cert-manager.io"
		rules: [{
			apiGroups: ["cert-manager.io", "acme.cert-manager.io"]
			apiVersions: ["*"]
			operations: ["CREATE", "UPDATE"]
			resources: ["*/*"]
		}]
		sideEffects:    "None"
		timeoutSeconds: 10
	}]
}

k8s: validatingwebhookconfigurations: "cert-manager-webhook": {
	apiVersion: "admissionregistration.k8s.io/v1"
	kind:       "ValidatingWebhookConfiguration"
	metadata: {
		annotations: "cert-manager.io/inject-ca-from-secret": "cert-manager/cert-manager-webhook-ca"
		labels: {
			app:                           "webhook"
			"app.kubernetes.io/component": "webhook"
			"app.kubernetes.io/instance":  "cert-manager"
			"app.kubernetes.io/name":      "webhook"
		}
		name: "cert-manager-webhook"
	}
	webhooks: [{
		admissionReviewVersions: ["v1", "v1beta1"]
		clientConfig: service: {
			name:      "cert-manager-webhook"
			namespace: "cert-manager"
			path:      "/validate"
		}
		failurePolicy: "Fail"
		name:          "webhook.cert-manager.io"
		namespaceSelector: matchExpressions: [{
			key:      "cert-manager.io/disable-validation"
			operator: "NotIn"
			values: ["true"]
		}, {
			key:      "name"
			operator: "NotIn"
			values: ["cert-manager"]
		}]
		rules: [{
			apiGroups: ["cert-manager.io", "acme.cert-manager.io"]
			apiVersions: ["*"]
			operations: ["CREATE", "UPDATE"]
			resources: ["*/*"]
		}]
		sideEffects:    "None"
		timeoutSeconds: 10
	}]
}
