// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

// TODO: replace by gatekeeper proxy
#proxyContainer: {
	#prefix:         string
	#serviceAccount: string
	#frontendPort:   number
	#backendPort:    number
	#extraArgs: [...string]

	name:  "\(#prefix)-proxy"
	image: config.images.proxy

	imagePullPolicy: "IfNotPresent"
	ports: [{
		containerPort: #frontendPort
		name:          "web"
	}]

	env: [{
		name: "NAMESPACE"
		valueFrom: fieldRef: fieldPath: "metadata.namespace"
	}]

	args: [
		"-provider=openshift",
		"-https-address=:\(#frontendPort)",
		"-http-address=",
		"-email-domain=*",
		"-pass-basic-auth=false",
		"-upstream=http://localhost:\(#backendPort)",
		"-client-id=system:serviceaccount:$(NAMESPACE):\(#serviceAccount)",
		"-openshift-ca=/etc/pki/tls/cert.pem",
		"-openshift-ca=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
		"-openshift-sar={\"resource\": \"namespaces\", \"verb\": \"get\", \"resourceName\": \"$(NAMESPACE)\", \"namespace\": \"$(NAMESPACE)\"}",
		"-tls-cert=/etc/tls/private/tls.crt",
		"-tls-key=/etc/tls/private/tls.key",
		"-client-secret-file=/var/run/secrets/kubernetes.io/serviceaccount/token",
		"-cookie-secret-file=/etc/proxy/secrets/session_secret",
	] + #extraArgs

	volumeMounts: [{
		mountPath: "/etc/tls/private"
		name:      "\(#prefix)-tls"
	}, {
		mountPath: "/etc/proxy/secrets"
		name:      "\(#prefix)-secrets"
	}]
}
