// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#GoogleAuth: {
	// Get credentials at https://console.cloud.google.com/apis/credentials
	clientID:     string
	clientSecret: string
}

#GCP: {
	// Name of a global static IP to be used for ingress.
	ingressStaticIPName: string
}

#Config: {
	images: {
		gerrit: "gcr.io/monogon-infra/gerrit@sha256:ceb3571b02baa878fe1498e6e39306ae14dc6d7ca5f3ea746b9e2861b1df4211"
	}

	// Hostname for Gerrit to run on (without https://)
	publicHostname: string

	// SSH hostname to advertise (defaults to publicHostname).
	sshHostname: *publicHostname | string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// UUID4 which identifies this instance.
	serverID: string

	// Google OAuth credentials
	googleAuth?: #GoogleAuth

	// SMTP authentication
	smtpServer: string
	smtpPort:   uint
	smtpUser:   string
	smtpPass:   string

	// Gerrit's own email address (for Git commits and notification mails)
	userEmail: string

	// Public SSH port requested from the cluster, either by means of a NodePort or
	// LoadBalancer object. The service needs to be manually deleted before
	// changing this on an existing cluster.
	sshPort: uint

	// If sshLoadBalancerIP is set, deploy a LoadBalancer. A NodePort is deployed otherwise.
	sshLoadBalancerIP?: string

	// Enable GCP support by specifying a GCP config.
	// This deploys a ingress + TLS cert on publicHostname.
	gcp?: #GCP

	// Enable deploying a Traefik IngressRoute.
	// TODO: replace by a plain Ingress object with annotations
	enableTraefik: *true | bool

	// Human-readable short name for the instance (will be part of the email subject line)
	instanceName: string

	// Custom title displayed in Gerrit's header
	headerName:            string
	headerBackgroundColor: string
	headerForegroundColor: string & =~"^#(?:[0-9a-fA-F]{3}){1,2}$"
	headerIcon:            string
	headerIconHeight:      string | *"1.2em"

	// Extra configuration to add to the main Gerrit config file
	extraConfig: string | *""

	// Replication config file ($site_path/etc/replication.config)
	replicationConfig: string | *""

	// Whether to reinitalize and reindex Gerrit on startup, ie. run `gerrit.war init -d $home`.
	//
	// For correctness, this is defaulted to true since our entrypoint has no way of knowing
	// when a reinitialization is required. This guarantees that plugins and indexes are
	// always up to date. On Monogon's instance, this is reasonably fast. On larger installations,
	// it might be necessary to disable this and manually reinitialize when required by a major upgrade.
	reinit: bool | *true
}

config: #Config
