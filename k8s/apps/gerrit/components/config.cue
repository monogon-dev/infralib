// Copyright 2020 The Monogon Project Authors.
// SPDX-License-Identifier: Apache-2.0

package components

#GoogleAuth: {
	// Get credentials at https://console.cloud.google.com/apis/credentials
	clientID:     string
	clientSecret: string
}

#Config: {
	images: {
		gerrit: "gcr.io/monogon-infra/gerrit:3.5.0-1@sha256:615eb21ea3de98889f369a8d3ecccf97d4f1c426f6c1ab0d289629abebcb5a6b"
	}

	// Hostname for Gerrit to run on (without https://)
	publicHostname: string

	// Wildcard domain to use for TLS termination
	publicDomain: string

	// UUID4 which identifies this instance.
	serverID: string

	// Google OAuth credentials
	googleAuth: #GoogleAuth

	// SMTP authentication
	smtpServer: string
	smtpPort:   uint
	smtpUser:   string
	smtpPass:   string

	// Gerrit's own email address (for Git commits and notification mails)
	userEmail: string

	// NodePort requested from the cluster. The service needs to be manually
	// deleted before changing this on an existing cluster.
	sshPort: uint & >=30000 & <=32767

	// Human-readable short name for the instance (will be part of the email subject line)
	instanceName: string

	// Custom title displayed in Gerrit's header
	headerName:            string
	headerBackgroundColor: string & =~"^#(?:[0-9a-fA-F]{3}){1,2}$"
	headerForegroundColor: string & =~"^#(?:[0-9a-fA-F]{3}){1,2}$"

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
