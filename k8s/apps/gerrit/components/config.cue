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
		// Don't forget to update javaHome when the base image was updated!
		gerrit: "gcr.io/monogon-infra/gerrit:3.4.1-2@sha256:325dba47a7924362477bdcc55941507ce2997bc2284ac7a7c74b77f978ea6c78"
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
	// This is temporarily required for some upgrades that include schema changes.
	reinit: bool | *false
}

config: #Config
