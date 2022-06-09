package components

if config.gcp != _|_ {
	k8s: managedcertificates: "gerrit": spec: domains: [config.publicHostname]

	k8s: frontendconfigs: "ssl-redirect": spec: redirectToHttps: enabled: true

	k8s: services: gerrit: metadata: annotations: "cloud.google.com/neg": #"{"ingress":true}"#

	// TODO: always use ingress
	k8s: ingresses: gerrit: {
		spec: defaultBackend: service: {
			name: "gerrit"
			port: number: 80
		}
	}

	k8s: ingresses: gerrit: metadata: annotations: {
		"kubernetes.io/ingress.class":                 "gce"
		"networking.gke.io/managed-certificates":      "gerrit"
		"networking.gke.io/v1beta1.FrontendConfig":    "ssl-redirect"
		"kubernetes.io/ingress.global-static-ip-name": config.gcp.ingressStaticIPName
	}
}
