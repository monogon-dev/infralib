package components

if config.enableTraefik {
	k8s: ingressroutes: "gerrit-tls": {
		spec: {
			entryPoints: ["websecure"]
			routes: [
				{
					match: "Host(`\(config.publicHostname)`) && PathPrefix(`/`)"
					kind:  "Rule"
					services: [
						{
							kind:     "Service"
							name:     "gerrit"
							port:     80
							protocol: "TCP"
						},
					]
				},
			]
		}
	}
}
