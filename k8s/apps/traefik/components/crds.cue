// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

k8s: crdsLegacy: [Name=string]: spec: {
	group:   "traefik.containo.us"
	version: "v1alpha1"
	scope:   "Namespaced"
	names: {
		kind:     string
		singular: string
		plural:   "\(singular)s"
	}
}

// TODO: Traefik has not published an OpenAPI schema for its CRDs

k8s: crdsLegacy: "ingressroutes.traefik.containo.us": spec: names: {
	kind:     "IngressRoute"
	plural:   "ingressroutes"
	singular: "ingressroute"
}

k8s: crdsLegacy: "middlewares.traefik.containo.us": spec: names: {
	kind:     "Middleware"
	plural:   "middlewares"
	singular: "middleware"
}

k8s: crdsLegacy: "ingressroutetcps.traefik.containo.us": spec: names: {
	kind:     "IngressRouteTCP"
	plural:   "ingressroutetcps"
	singular: "ingressroutetcp"
}

k8s: crdsLegacy: "ingressrouteudps.traefik.containo.us": spec: names: {
	kind:     "IngressRouteUDP"
	plural:   "ingressrouteudps"
	singular: "ingressrouteudp"
}

k8s: crdsLegacy: "tlsoptions.traefik.containo.us": spec: names: {
	kind:     "TLSOption"
	plural:   "tlsoptions"
	singular: "tlsoption"
}

k8s: crdsLegacy: "tlsstores.traefik.containo.us": spec: names: {
	kind:     "TLSStore"
	plural:   "tlsstores"
	singular: "tlsstore"
}

k8s: crdsLegacy: "traefikservices.traefik.containo.us": spec: names: {
	kind:     "TraefikService"
	plural:   "traefikservices"
	singular: "traefikservice"
}

k8s: crdsLegacy: "serverstransports.traefik.containo.us": spec: names: {
	kind:     "ServersTransport"
	plural:   "serverstransports"
	singular: "serverstransport"
}

k8s: crdsLegacy: "middlewaretcps.traefik.containo.us": spec: names: {
	kind:     "MiddlewareTCP"
	plural:   "middlewaretcps"
	singular: "middlewaretcp"
}
